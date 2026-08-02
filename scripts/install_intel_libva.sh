#!/bin/bash
set -euo pipefail

# https://github.com/intel/libva#build-and-install-libva
apt-get install -y git cmake pkg-config meson libdrm-dev automake libtool
cd libva
./autogen.sh --prefix=/usr/local --libdir=/usr/local/lib
make -j$(nproc)
make install
cd ..
ldconfig