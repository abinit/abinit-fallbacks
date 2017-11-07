#!/bin/bash

. /usr/share/lmod/lmod/init/bash
module use /home/pouillon/retos/HPC/modules/all
module load foss/2016b
module load HDF5/1.8.17-foss-2016b

set -e

cmd="${1}"

./wipeout.sh
./autogen.sh
mkdir tmp
cd tmp
../configure \
  --enable-local-build \
  --with-linalg-libs="-lopenblas" \
  CC="gcc" \
  FC="gfortran"

test "${cmd}" != "no-make" && make dist
test "${cmd}" != "no-make" && make -j4
test "${cmd}" != "no-make" && make install
