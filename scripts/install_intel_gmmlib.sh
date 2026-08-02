#!/bin/bash
set -euo pipefail

# https://github.com/intel/gmmlib#building
cd gmmlib
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib ..
make -j$(nproc)
make install
cd ../..
ldconfig
