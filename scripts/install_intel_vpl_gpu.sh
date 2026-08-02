#!/bin/bash
# https://github.com/intel/vpl-gpu-rt#build-steps
rm -rf ./vpl-gpu-rt/build
mkdir -p ./vpl-gpu-rt/build && cd ./vpl-gpu-rt/build
cmake ..
make
make install
ldconfig
cd ../..