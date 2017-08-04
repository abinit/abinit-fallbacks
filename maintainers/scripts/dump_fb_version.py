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
import glob
import socket

try:
    from ConfigParser import ConfigParser
except ImportError:
    from configparser import ConfigParser

#
NamesExceptions={ 'netcdf4':'netcdf', 'netcdf4_fortran':'netcdf-fortran' }
def RenameException(fallback):
    try:
        return NamesExceptions[fallback]
    except:
        return fallback

def Check_If_Installed(basedir,fallback,version):
    return os.path.isdir("%s/%s/%s" % ( basedir,RenameException(fallback),version ))

# ---------------------------------------------------------------------------- #

my_name    = "dump_fb_versions.py"
my_config  = "../config/specs/fallbacks.conf"
hostname   = socket.gethostname().split(".")[0]
builder    = os.popen("module -t list 2>&1 | grep `hostname -s`").readlines()[0].strip()

if builder.split("_")[0] != hostname:
   print("The builder name (%s) is not consistent with the hostname : %s" % (builder,hostname) )
   print("Aborting now...") 
   sys.exit(3)

# Check if we have a config file
if ( not os.path.exists(my_config) ):
  print("%s: Could not find config file (%s)." % (my_name,my_config))
  print("%s: Aborting now." % my_name)
  sys.exit(2)

# 
#parser = argparse.ArgumentParser()
#parser.add_argument("builder", type=str, default="yquem_gnu_6.3_serial", nargs='?', help="name of builder ( == module name )")
#args = parser.parse_args()
#d = vars(args)
#builder=d['builder']


# Process config file
cnf = ConfigParser()
cnf.read(my_config)

fallbacks=cnf.sections()

fbks_version={}       # version of fbks

for fallback in fallbacks:
  cnf_vars = dict(cnf.items(fallback))
  version=cnf_vars['name'].split("-")[-1]
  if fallback == "linalg":
       version=cnf_vars['name'].split("_")[-1]
  fbks_version[fallback]=version

slave,vendor,version,variant = builder.split('_')
fbk_prefix_base="/usr/local/fallbacks/%s/%s/%s" % ( vendor,version,variant )
print('-------------------------------------------------')
print('prefix : %s' % fbk_prefix_base)


#############################################
# fallbacks/config/specs/fallbacks.conf

print('-------------------------------------------------')
print('versions in fallbacks/config/specs/fallbacks.conf')
print('-------------------------------------------------')
for fbk in fallbacks:
    f = RenameException(fbk)
    print("%s : %s" %(f,fbks_version[fbk]))

#############################################
# check all versions of fb installed

print('\n------------------------------------------------')
print('all versions of installed external fallbacks')
print('------------------------------------------------')

for fbk in fallbacks:
    #f = RenameException(fbk)
    f = fbk
    t= glob.glob('%s/%s/*' % (fbk_prefix_base,f))
    #print(t)
    if len(t) != 0:
        print("%s : " % f, end='')
        for i in t:
           tmp=i.split("/")[-1]
           print(tmp, end=' / ')
           #print(tmp.split("-")[1],end=' / ')
           #print(glob.glob('%s/%s-*' % (fbk_prefix_base,f)))
        print()
    else:
        print("%s not installed" % f)

#############################################
# version fb prod

print('\n--------------------------------------------')
print('versions of external fallbacks used for prod')
print('--------------------------------------------')

for fbk in fallbacks:
    #f = RenameException(fbk)
    f = fbk
    try:
       #version=os.readlink("%s/%s" % ( fbk_prefix_base,f)).split("-")[1]
       version=os.readlink("%s/%s" % ( fbk_prefix_base,f))
       print("%s : %s" % (f,version))
    except:
       print("%s not installed" % f)

sys.exit()
