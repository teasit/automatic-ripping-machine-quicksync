#!/bin/bash
set -euo pipefail

# https://github.com/intel/libva-utils#build-and-install-libva-utils
cd libva-utils
./autogen.sh --prefix=/usr/local --libdir=/usr/local/lib
make -j$(nproc)
make install
cd ..
ldconfig