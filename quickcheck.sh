#!/bin/sh

set -e

cmd="${1}"

./wipeout.sh
./autogen.sh
mkdir tmp
cd tmp
../configure \
  --enable-local-build \
  --with-linalg-libs="-llapack -lblas"

test "${cmd}" != "no-make" && make dist
test "${cmd}" != "no-make" && make -j4
test "${cmd}" != "no-make" && make install
