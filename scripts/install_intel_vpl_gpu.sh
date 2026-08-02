#!/bin/bash
set -euo pipefail

# https://github.com/intel/vpl-gpu-rt#build-steps
mkdir -p ./vpl-gpu-rt/build && cd ./vpl-gpu-rt/build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib
make -j$(nproc)
make install
cd ../..
ldconfig