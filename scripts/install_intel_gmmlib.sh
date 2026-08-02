#!/bin/bash
# https://github.com/intel/gmmlib#building
cd gmmlib
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
make install
