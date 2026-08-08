#!/bin/bash
set -euo pipefail

# Also allows to build x11 and glx support for libva, which is required for some applications like HandBrakeCLI.
apt-get install -y libx11-xcb-dev libxcb-dri3-dev \

# https://github.com/intel/libva#build-and-install-libva
apt-get install -y git cmake pkg-config meson libdrm-dev automake libtool
cd libva
./autogen.sh \
  --prefix=/usr/local \
  --libdir=/usr/local/lib \
  --enable-x11 \
  --enable-glx
make -j$(nproc)
make install
cd ..
ldconfig