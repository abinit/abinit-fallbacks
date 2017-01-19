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

def Check_If_Installed(basedir,fallback,version):
    return os.path.isdir("%s/%s/%s" % ( basedir,fallback,version ))

# ---------------------------------------------------------------------------- #

my_name    = "dump_fb_version.py"
my_config  = "config/specs/fallbacks.conf"
hostname   = socket.gethostname().split(".")[0]

# Check if we have a config file
if ( not os.path.exists(my_config) ):
  print("%s: Could not find config file (%s)." % (my_name,my_config))
  print("%s: Aborting now." % my_name)
  sys.exit(2)

# 
parser = argparse.ArgumentParser()
parser.add_argument("-l","--link", action="store_true", help="create links")
parser.add_argument("-y","--yes", action="store_true", help="yes answer by default")
parser.add_argument("builder", type=str, default="yquem_gnu_6.3_serial", nargs='?', help="name of builder ( == module name )")
args = parser.parse_args()

d = vars(args)
link=d['link']
yes=d['yes']
builder=d['builder']
if builder.split("_")[0] != hostname:
   print("The builder name (%s) is not consistent whith the hostname : %s" % (builder,hostname) )
   print("Aborting now...") 
#sys.exit()

# Process config file
cnf = ConfigParser()
cnf.read(my_config)

fallbacks=cnf.sections()

fbks_version={}       # version of fbks

for fallback in fallbacks:
  cnf_vars = dict(cnf.items(fallback))
  version=cnf_vars['name'].split("-")[1]
  if fallback == "linalg":
       version=cnf_vars['name'].split("_")[1]
  fbks_version[fallback]=version

if not link:
  for k,v in fbks_version.iteritems():
    print("%s : %s" %(k,v))
  sys.exit()

# create links
slave,vendor,version,variant = builder.split('_')
fbk_prefix_base="/usr/local/fallbacks/%s/%s/%s" % ( vendor,version,variant )

fallbacks.remove('linalg')

for f in fallbacks:
    if Check_If_Installed(fbk_prefix_base,f,fbks_version[f]):
        print("%s exists" % f)
    else:
        print("%s missing" % f)
        link=False

if not link and not yes:
    msg="Not all fallbacks are presents, proceed anyway ?"
    if raw_input("%s (y/N) " % msg).lower() != 'y':
       print("Exit...")
       sys.exit()

#############################################
# create links
# TODO : rm old links before

for fb in fallbacks:
    print(fb)
    for d in ['bin','lib','include']:
      if not os.path.exists("%s/%s" % (fbk_prefix_base,d)):
	os.makedirs("%s/%s" % (fbk_prefix_base,d))
      os.chdir("%s/%s" % (fbk_prefix_base,d))
      folder="../%s/%s/%s" % (fb,fbks_version[fb],d)
      if os.path.exists(folder) :
         for file in os.listdir(folder):
             if file == 'abinit-fallbacks-config' or file == 'pkgconfig':
                 continue
             subprocess.call(['ln', '-s', "%s/%s" % (folder,file)])
