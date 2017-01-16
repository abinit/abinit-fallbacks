#!/usr/bin/env python
#
# Copyright (C) 2009-2017 ABINIT Group (Jean-Michel Beuken)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#
from __future__ import print_function, division, absolute_import #, unicode_literals

import sys,os,re
import argparse
import subprocess
from pymongo import MongoClient

try:
    from ConfigParser import ConfigParser
except ImportError:
    from configparser import ConfigParser

def OpenMongoConnection():
    uri="mongodb://bbro:bbro@gitlab.pcpm.ucl.ac.be/buildbot"
    return  MongoClient(uri)

def Check_If_Installed(basedir,fallback,version):
    return os.path.isdir("%s/%s/%s" % ( basedir,fallback,version ))

# ---------------------------------------------------------------------------- #

my_name    = "Build_FB4BB.py"
my_config  = "config/specs/fallbacks.conf"

# Check if we have a config file
if ( not os.path.exists(my_config) ):
  print("%s: Could not find config file (%s)." % (my_name,my_config))
  print("%s: Aborting now." % my_name)
  sys.exit(2)

# Process config file
cnf = ConfigParser()
cnf.read(my_config)

fallbacks=cnf.sections()

A={} # working variable

fbks_list_depends={}  # contains depends by fbks
fbks_version={}       # version of fbks
fbks_sorted_list=[]   # list of fbks sorted by number of dependencies

for fallback in fallbacks:
  cnf_vars = dict(cnf.items(fallback))
  list_depends=[]
  if cnf_vars['depends'] != "none":
       list_depends=cnf_vars['depends'].split(" ")
  version=cnf_vars['name'].split("-")[1]
  if fallback == "linalg":
       version=cnf_vars['name'].split("_")[1]
  A[fallback]=len(list_depends)
  fbks_list_depends[fallback]=list_depends
  fbks_version[fallback]=version

tmp=sorted(A.items(), key=lambda x: x[1])
for i in range(0,len(fallbacks)):
  fbks_sorted_list=fbks_sorted_list+[tmp[i][0]]

#print(fbks_sorted_list)
# ['libxc', 'linalg', 'yaml', 'netcdf', 'wannier90', 'atompaw', 'bigdft']
#print(fbks_list_depends)
# {'wannier90': ['linalg'], 'libxc': [], 'linalg': [], 'bigdft': ['linalg', 'netcdf', 'libxc', 'yaml'], 'yaml': [], 'netcdf': [], 'atompaw': ['linalg', 'libxc']}
#print(fbks_version)
# {'wannier90': '2.0.1.1', 'libxc': '2.2.3', 'linalg': '6.10', 'bigdft': '1.7.1.23', 'yaml': '0.1.6', 'netcdf': '4.1.1', 'atompaw': '4.0.0.14'}

fbk_libs={}
for f in fbks_sorted_list:
    if f == 'libxc':
           fbk_libs[f]="-lxcf90 -lxc"
    else:
        fbk_libs[f]="-l%s" % f

#
parser = argparse.ArgumentParser()
parser.add_argument("-l","--linalg", action="store_true", help="build LinAlg")
parser.add_argument("-b","--bigdft", action="store_true", help="build BigDFT")
parser.add_argument("-n","--netcdf", action="store_true", help="build NetCDF")
parser.add_argument("-a","--atompaw", action="store_true", help="build Atompaw")
parser.add_argument("-x","--libxc", action="store_true", help="build libXC")
parser.add_argument("-w","--wannier90", action="store_true", help="build Wannier90")
parser.add_argument("-y","--yaml", action="store_true", help="build yaml")
parser.add_argument("-A","--all", action="store_false", help="build all fallbacks")
parser.add_argument("-p","--prod", action="store_true", help="install all fbks with same prefix")
parser.add_argument("builder", type=str, help="name of builder ( == module name )")
args = parser.parse_args()

d = vars(args)

builder=d['builder']
d.pop('builder', None)

prod_prefix=d['prod']
d.pop('prod', None)

# list of fbk to install
rc=False
for f in fbks_sorted_list:
  rc = rc or d[f]
  if rc :
    d['all']=False
    break

# if --all, install all fbks
if not rc:
  for f in fbks_sorted_list:
      d[f]=True
else: # if not all, compute the depends
  #print("%s depends of %s" % (f,fbks_list_depends[f]))
  if fbks_list_depends[f] != []:
     for dp in fbks_list_depends[f]:
         d[dp]=True

d.pop('all', None)

##############################################
# connection to mongodb local

client = OpenMongoConnection()

# get fallback_options
db_builders = client.buildbot.builders
fbk_options=db_builders.find_one({ 'name': builder })['fallback_options']
#print fbk_options
client.close()


##############################################
# external linalg is used by defaut with BB
try:
  if fbk_options['LINALG'] != "":
     print("\n*** Use external linalg : ",fbk_options['LINALG'])
     d.pop('linalg', None)
except:
  pass

##############################################
#
# build the install dir basename
slave,vendor,version,variant = builder.split('_')
fbk_prefix_base="/usr/local/fallbacks/%s/%s/%s" % ( vendor,version,variant )

# find which fb will be installed 
tmpfb=[]
for k,v in d.iteritems():
   if v:
      tmpfb.append(k)

# Check if some fbk are already installed
already_installed=[]
for f in tmpfb:
    if Check_If_Installed(fbk_prefix_base,f,fbks_version[f]):
        already_installed.append(f)

for f in already_installed:
    tmpfb.remove(f)

will_be_installed=[]
for f in fbks_sorted_list:
    if f in tmpfb:
        will_be_installed.append(f)

if len(will_be_installed) == 0:
    print("Nothing todo...\n")
    sys.exit(0)

print("\nWill be installed : %s \n" % will_be_installed)

##############################################
# create a Configure file with configure cmd
#

# create tmp dir to build fbks
directory="tmp_%s" % builder
if not os.path.exists(directory):
    os.makedirs(directory)

filename="%s/Configure" % directory
try:
   os.remove(filename)
except OSError:
   pass

# create prefix where installing fbk
#
for fb in will_be_installed:

  if prod_prefix:
      fbk_prefix=fbk_prefix_base
  else:
      fbk_prefix="%s/%s/%s" % (fbk_prefix_base,fb,fbks_version[fb])

  with open(filename,"a") as fn:
      fn.write('# build %s \n' % fb)
      fn.write('../configure \\\n')
      fn.write('  --prefix=%s \\\n' % fbk_prefix )
      # list of depends
      for f in  fbks_list_depends[fb]: 
           if f == 'linalg':
               fn.write('  --with-linalg-libs=\"%s\" \\\n' % fbk_options['LINALG'])
           else:
              fn.write('  --with-%s-libs=\"-L%s/%s/%s/lib %s\" \\\n' % (f,fbk_prefix_base,f,fbks_version[f],fbk_libs[f]))
              fn.write('  --with-%s-incs=\"-I%s/%s/%s/include\" \\\n' % (f,fbk_prefix_base,f,fbks_version[f]))
      # disable all others fbks
      fn.write('  ')
      for f in fbks_sorted_list:
          if f == fb :
              continue
          if f in fbks_list_depends[fb]:
              continue
          fn.write('--disable-%s ' % f)
      fn.write('\\\n')
      fn.write('  FC=%s CC=%s CXX=%s \nmake -j 4 install\n\n' % (fbk_options['FC'],fbk_options['CC'],fbk_options['CXX']))

subprocess.call(['chmod', '0750', filename])

# cd to tmp dir
#os.chdir(directory)
