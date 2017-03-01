#!/bin/bash
#
# Copyright (C) 2009-2017 ABINIT Group (Jean-Michel Beuken)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

# get name of fallbacks 

fbks=`egrep '^\[[a-z0-9]*\]' ../fallbacks.conf | sed -e 's/\[\(.*\)\]/\1/'`

for i in $fbks; do
  version=`egrep "^name = (lib)?$i-.*" ../fallbacks.conf | cut -d- -f2;`
  if [ "x$version" != "x" ]; then
     #echo "$i-$version.cfg $i.cfg"
     if [ "$i" == "psml" ]; then i="libpsml"; fi
     ln -s $i-$version.cfg $i.cfg
  fi
done

exit 0

#ls -1 *.cfg | sed -e 'p;s/\(.*\)-.*/\1.cfg/' | xargs -n 2 ln -s
#rm -f lapack.cfg
