#!/bin/bash

# Init build environment
#. /usr/share/module/init/bash
module purge
module load eos_gnu_13.2_openmpi

# Stop at first error
set -e

# Init source tree
cmd="${1}"
./wipeout.sh
./autogen.sh

# Build only external linear algebra
mkdir tmp-linalg
cd tmp-linalg
../configure \
  --enable-local-build \
  --with-linalg-libs="-L${MKLROOT}/lib/intel64 -Wl,--start-group  -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group" \
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
