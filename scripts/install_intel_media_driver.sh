#!/bin/bash
set -euo pipefail

# https://github.com/intel/media-driver#building
apt install autoconf libtool libdrm-dev xorg xorg-dev openbox libx11-dev libgl1-mesa-glx
rm -rf build_meta
mkdir -p build_meta
cd build_meta
cmake ../media-driver -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib -DLIBVA_DRIVERS_PATH=/usr/local/lib/dri
make -j$(nproc)
make install
cd ..
ldconfig

# Expected to be set in dockerfile:
# export LIBVA_DRIVERS_PATH=/usr/local/lib/dri
# export LIBVA_DRIVER_NAME=iHD