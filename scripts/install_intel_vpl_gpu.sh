#!/bin/bash
set -euo pipefail

# https://github.com/intel/vpl-gpu-rt#build-steps
mkdir -p ./vpl-gpu-rt/build && cd ./vpl-gpu-rt/build
cmake ..
make -j$(nproc)
make install
cd ../..