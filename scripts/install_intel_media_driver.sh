#!/bin/bash
# https://github.com/intel/media-driver#building
apt install autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx
rm -rf build_meta
mkdir -p build_meta
cd build_meta
cmake ../media-driver
make -j$(nproc)
make install
cd ..

# TODO: Check if this is required...
# export LIBVA_DRIVERS_PATH=<path-contains-iHD_drv_video.so>
# export LIBVA_DRIVER_NAME=iHD

# TODO: Currently throws these errors:
#   E: Unable to locate package xorg
#   E: Unable to locate package xorg-dev
#   E: Unable to locate package openbox
#   E: Unable to locate package libgl1-mesa-glx