#!/usr/bin/env python3

import argparse
import sys

import abinit.fallbacks.package as afb_pkg


                    ########################################


# Declare command-line arguments
parser = argparse.ArgumentParser()
parser.add_argument("action",
    help="Fallback action to perform")
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
    fbk_list = args.filter.split(",")
else:
    fbk_list = None

# Create sequence for requested packages
fbk_seq = FallbackSequence(os.path.join(cfgdir, abinit_version, fbk_list)

print(fbk_seq)
