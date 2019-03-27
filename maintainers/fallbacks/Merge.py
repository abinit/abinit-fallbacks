#!/usr/bin/env python
#
# Copyright (C) 2009-2017 ABINIT Group (Jean-Michel Beuken)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

from __future__ import print_function, division, absolute_import

import os,sys
import argparse
import re

filename="fallbacks.conf"

parser = argparse.ArgumentParser()
parser.add_argument("-p","--libpsml", dest="libpsml", help="version PSML")
parser.add_argument("-m","--xmlf90", dest="xmlf90", help="version xmlf90")
parser.add_argument("-x","--libxc", dest="libxc", help="version libXC")
parser.add_argument("-l","--linalg", dest="linalg", help="version LinAlg")
parser.add_argument("-b","--bigdft", dest="bigdft", help="version BigDFT")
parser.add_argument("-n","--netcdf", dest="netcdf", help="version NetCDF")
parser.add_argument("-a","--atompaw", dest="atompaw", help="version Atompaw")
parser.add_argument("-w","--wannier90", dest="wannier90", help="version Wannier90")
args = parser.parse_args()

vers = vars(args)
#print(vers['bigdft'])

os.system("cat header.conf > "+filename)
concat = ""
res = [f for f in os.listdir(".") if re.search('^[a-z0-9]*\.cfg', f)]
for file in res:
    if file == 'libpsml.cfg':
        f=vers['libpsml']
    else:
        f=vers[file.split('.')[0]]
    if f != None :
        file = file.split('.')[0]+"-"+f+".cfg"
        #print("file : %s " % file)
    concat += open(file).read()
    concat += "\n"
with open(filename,"a") as f:
    f.write(concat)

#sys.exit()
