#!/bin/bash

# Init build environment
. /usr/share/lmod/lmod/init/bash
module use /home/pouillon/retos/hpc/modules/all
module purge
module load foss/2016b
module load HDF5/1.8.17-foss-2016b

# Stop at first error
set -e

# Init source tree
cmd="${1}"
./wipeout.sh
./autogen.sh

# Build using external linear algebra
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

# Build only internal linear algebra
cd ..
mkdir tmp-linalg
cd tmp-linalg
../configure \
  --enable-local-build \
  --enable-linalg \
  --disable-atompaw \
  --disable-bigdft \
  --disable-libpsml \
  --disable-libxc \
  --disable-netcdf4 \
  --disable-netcdf4-fortran \
  --disable-wannier90 \
  --disable-xmlf90 \
  CC="gcc" \
  FC="gfortran"

test "${cmd}" != "no-make" && make dist
test "${cmd}" != "no-make" && make -j4
test "${cmd}" != "no-make" && make install
