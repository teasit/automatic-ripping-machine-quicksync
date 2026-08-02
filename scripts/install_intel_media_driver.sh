#!/bin/bash
set -euo pipefail

# https://github.com/intel/media-driver#building
apt-get update
apt-get install -y --no-install-recommends autoconf automake cmake libdrm-dev libtool libx11-dev libxext-dev libxfixes-dev pkg-config
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
