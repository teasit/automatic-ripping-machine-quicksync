#!/bin/bash
# https://github.com/intel/vpl-gpu-rt#build-steps
mkdir -p ./vpl-gpu-rt/build && cd ./vpl-gpu-rt/build
cmake ..
make
make install
ldconfig
cd ../..