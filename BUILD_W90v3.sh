#!/bin/bash

DEBUG=0
FALLBACKS_PATH="../config/specs"
FALLBACKS_CFG="../config/specs/fallbacks.cfg"

######################################
# CHECK if wannier90 is enabled

grep -v "^#" Configure | grep -q -- "[ ]*--disable-wannier90"

if [ "`echo $?`" == "0" ]; then
  echo "Wannier90 disabled..."
  exit
fi

######################################
# CHECK version of fallback package

Version=`egrep -o -m 1 "^\[(.*)\]$" ${FALLBACKS_CFG} | sed 's/^\[\(.*\)\]/\1/'`
echo $Version

######################################
# CHECK version of wannier90 needed

WANNIER90_VERS=`grep -m 1 wannier90 ${FALLBACKS_CFG} |sed -e "s/ //g"| cut -d"=" -f2`
echo $WANNIER90_VERS

if [ "${WANNIER90_VERS:0:1}" -lt "3" ]; then
 echo "Build Wannier90 2.x by Configure"
 grep -v "^#" Configure | grep -q -- "[ ]*--enable-wannier90"
 if [ "`echo $?`" == "1" ]; then
   echo "add --enable-wannier90 in Configure..."
   sed -i -e '/--prefix=*/a   \ \ --enable-wannier90 \\' Configure
 else
   echo "Build of Wannier90 disabled..."
   exit
 fi
fi

echo "Need to build Wannier90 3.x"

##############################################
# Configure should no longer compile Wannier

sed -i -e '/--prefix=*/a   \ \ --disable-wannier90 \\' Configure

######################################
# WGET wannier90

LOCAL_TARBALL="${HOME}/.abinit/tarballs"

if test -f "${LOCAL_TARBALL}/wannier90-${WANNIER90_VERS}.tar.gz"; then
     tar xzf ${LOCAL_TARBALL}/wannier90-${WANNIER90_VERS}.tar.gz
else
     URL=`https://github.com/wannier-developers/wannier90/archive/v${WANNIER90_VERS}.tar.gz`
     URL=`grep "\[${WANNIER90_VERS}\]" -A 4 ${FALLBACKS_PATH}/wannier90.cfg | egrep -m 1 https?`
     wget $URL
     tar xzf v${WANNIER90_VERS}.tar.gz
     rm v${WANNIER90_VERS}.tar.gz
fi

######################################
# BUILD PATHs

PWD=`pwd`
PathName=`basename $PWD | awk -F_ '{print $3"/"$4"/"$5}'`
Prefix="/usr/local/fallbacks_$Version/$PathName"
echo $Prefix

WANNIER90_DIR=`find . -type d -name "wannier90*"`
WANNIER90_VERSION=`echo ${WANNIER90_DIR##*/} | cut -d"-" -f2`
echo $WANNIER90_VERSION

######################################
# DETECT compiler

MPI=""

compiler=`grep -oE 'FC=[[:alnum:]]*' Configure | sed -e 's/FC=//'`
echo $compiler

MPI=`echo $compiler| awk '{print substr($0,0,3)}'`
if [ "${MPI}" == "mpi" ]; then
   echo "MPI detected"
   MPI="mpi"

   real_compiler=`$compiler -show|cut -d" " -f1`
   echo $real_compiler
else
   real_compiler=$compiler
   compiler=""
   MPI=""
fi

cd $WANNIER90_DIR

######################################
# BUILD make.inc

cat <<EOF > make.inc
F90 = $real_compiler

COMMS = $MPI
MPIF90 = $compiler

FCOPTS = -O3
LDOPTS =

EOF

LINALG=`grep with-linalg-libs ../Configure`
LINALG=`echo "$LINALG" | cut -d'"' -f 2`
echo "LIBS = $LINALG"  >> make.inc

exit

######################################
# BUILD library
make -j 8 lib

######################################
# MAKE INSTALL

install -d  $Prefix/wannier90/$WANNIER90_VERS/lib
cp libwannier.a $Prefix/wannier90/$WANNIER90_VERS/lib/libwannier90.a
ln -s $Prefix/wannier90/$WANNIER90_VERS $Prefix/wannier90/default
