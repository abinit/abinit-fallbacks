#!/bin/sh
#
# Copyright (C) 2013-2014 ABINIT group (Yann Pouillon)
#
# This file is part of the Abinit Fallbacks software package. For license
# information, please see the COPYING file in the top-level directory of
# the source distribution.
#

#
# IMPORTANT NOTE:
#
#   For maintainer use only!
#
#   PLEASE DO NOT EDIT THIS FILE, AS IT COULD CAUSE A SERIOUS LOSS OF DATA.
#   *** YOU HAVE BEEN WARNED! ***
#

# Check that we are in the right directory
if test ! -s "./configure.ac" -o ! -s "config/specs/fallbacks.conf"; then
  echo "[fbkclean]   Cowardly refusing to remove something from here!" >&2
  exit 1
fi

# Remove temporary directories and files
echo "[fbkclean]   Removing temporary directories and files"
rm -rf tmp*
find . -depth -name 'tmp-*' -exec rm -rf {} \;

# Remove autotools files
echo "[fbkclean]   Removing autotools files"
rm -f core config.log config.status stamp-h1 config.h config.h.in*
rm -rf aclocal.m4 autom4te.cache configure confstat*
(cd config/gnu && rm -f config.guess config.sub depcomp install-sh ltmain.sh missing)
(cd config/m4 && rm -f libtool.m4 ltoptions.m4 ltsugar.m4 ltversion.m4 lt~obsolete.m4 auto-*.m4)

# Remove Makefiles and machine-generated files
echo "[fbkclean]   Removing files produced by the configure script"
rm -f libtool
find . -name Makefile -exec rm {} \;
find . -name Makefile.in -exec rm {} \;

# Remove object files, libraries and programs
echo "[fbkclean]   Removing object files, libraries and programs"
rm -rf exports/* sources/* stamps/*
