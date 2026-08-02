#!/bin/bash
set -euo pipefail

# https://github.com/intel/libva#build-and-install-libva
apt-get install -y git cmake pkg-config meson libdrm-dev automake libtool
cd libva
./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make -j$(nproc)
make install
cd ..