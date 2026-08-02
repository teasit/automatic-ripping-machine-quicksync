#!/bin/bash
# https://github.com/intel/libva-utils#build-and-install-libva-utils
cd libva-utils
./autogen.sh
make
make install
cd ..