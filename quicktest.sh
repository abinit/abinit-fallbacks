#!/bin/sh

./wipeout.sh && \
./autogen.sh && \
mkdir tmp && \
cd tmp && \
../configure \
  --enable-local-build \
&& \
make -j4
