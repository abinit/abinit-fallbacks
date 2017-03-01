#!/bin/bash
#
# Copyright (C) 2009-2017 ABINIT Group (Jean-Michel Beuken)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

list=`ls -1 *.cfg | grep -v '-'`
for i in $list; do
  rm -f $i
done
rm -f fallbacks.conf
