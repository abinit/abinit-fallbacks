#!/bin/sh

cmd="${1}"

./wipeout.sh && \
./autogen.sh && \
mkdir tmp && \
cd tmp && \
../configure \
  --enable-local-build

test "${cmd}" != "no-make" && make dist
test "${cmd}" != "no-make" && make -j4
