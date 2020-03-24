#!/usr/bin/env python3

import argparse
import sys,os

#import abinit.fallbacks.sequence as afb_seq
#import abinit.fallbacks.package as afb_pkg

from abinit.fallbacks import sequence
from abinit.fallbacks import package


                    ########################################

# Declare command-line arguments
parser = argparse.ArgumentParser()
#parser.add_argument("action",
#    help="Fallback action to perform")
parser.add_argument("-a", "--abinit", metavar="VERSION",
    help="Select Abinit version X.Y")
parser.add_argument("-c", "--cfgdir",
    help="Look for config files in specified config directory")
parser.add_argument("-f", "--filter", metavar="PACKAGES",
    help="Only consider the comma-separated list of packages")
parser.add_argument("-p", "--prefix", metavar="DIRECTORY",
    help="Installation prefix for the fallbacks")
args = parser.parse_args()

# Process command-line arguments
if ( args.abinit ):
    abinit_version = args.abinit
else:
    abinit_version = None
if ( args.cfgdir ):
    cfgdir = args.cfgdir
else:
    cfgdir = os.path.join("config", "specs")
if ( args.filter ):
    fbk_filter = args.filter.split(",")
else:
    fbk_filter = None

# Create sequence for requested packages
#fbk_seq = sequence.FallbackSequence(cfgdir, abinit_version, fbk_filter)
#print(fbk_seq)

#fbk_pck = package.FallbackPackage(cfgdir, "atompaw")
fbk_pck = package.FallbackPackage(cfgdir, fbk_filter)
print(fbk_pck)
