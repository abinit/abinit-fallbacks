#!/usr/bin/env python
#
# Copyright (C) 2009-2017 ABINIT Group (Jean-Michel Beuken)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#
from __future__ import print_function, division, absolute_import #, unicode_literals

import sys,re
import os,errno
import argparse
import subprocess
import glob
import socket

try:
    from ConfigParser import ConfigParser
except ImportError:
    from configparser import ConfigParser

#
NamesExceptions={ 'psml' : 'libpsml' }
def RenameException(fallback):
    try:
        return NamesExceptions[fallback]
    except:
        return fallback

def Check_If_Installed(basedir,fallback,version):
    return os.path.isdir("%s/%s-%s" % ( basedir,RenameException(fallback),version ))

# ---------------------------------------------------------------------------- #

my_name    = "create_links4fbks.py"
my_config  = "config/specs/fallbacks.conf"
hostname   = socket.gethostname().split(".")[0]

# Check if we have a config file
if ( not os.path.exists(my_config) ):
  print("%s: Could not find config file (%s)." % (my_name,my_config))
  print("%s: Aborting now." % my_name)
  sys.exit(2)

# 
parser = argparse.ArgumentParser()
parser.add_argument("-l","--link", action="store_true", help="create fallbacks links")
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
   sys.exit(3)

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

if not link :
  for k,v in fbks_version.iteritems():
    print("%s : %s" %(k,v))
  sys.exit()

#############################################
# create links

slave,vendor,version,variant = builder.split('_')
fbk_prefix_base="/usr/local/fallbacks/%s/%s/%s" % ( vendor,version,variant )

fallbacks.remove('linalg')

LINK=True
if not yes:
  for f in fallbacks:
    f2 = RenameException(f)
    if Check_If_Installed(fbk_prefix_base,f2,fbks_version[f]):
        print("%s exists" % f) 
    else:
        print("%s missing" % f)
        LINK=False

if not LINK and not yes:
    msg="Not all fallbacks are presents, proceed anyway ?"
    if raw_input("%s (y/N) " % msg).lower() != 'y':
       print("Exit...")
       sys.exit()

# fallbacks links
base="%s" % fbk_prefix_base
if link:
  os.chdir(base)
  for fb in fallbacks:
    fb2 = RenameException(fb)
    src="%s-%s" % (fb2,fbks_version[fb])
    tgt="%s" % (fb2)
    try:
        if not yes:
            print("%s -> %s" % (src,tgt))
        os.symlink(src,tgt)
    except OSError, e:
        if e.errno == errno.EEXIST:
           os.remove(fb2)
           os.symlink(src,tgt)
        else:
           print("problem with link creation : ",fb2)

if not yes:
    print("done...")
sys.exit()
