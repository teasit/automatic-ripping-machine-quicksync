#!/bin/bash
set -euo pipefail

# https://github.com/intel/media-driver#building
apt install autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx
rm -rf build_meta
mkdir -p build_meta
cd build_meta
cmake ../media-driver
make -j$(nproc)
make install
cd ..

# Expected to be set in dockerfile:
# export LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri
# export LIBVA_DRIVER_NAME=iHD

# TODO: Currently throws these errors:
#   E: Unable to locate package xorg
#   E: Unable to locate package xorg-dev
#   E: Unable to locate package openbox
#   E: Unable to locate package libgl1-mesa-glx