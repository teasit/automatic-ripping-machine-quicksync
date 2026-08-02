#!/bin/bash
# https://github.com/intel/libva#build-and-install-libva
apt-get install -y git cmake pkg-config meson libdrm-dev automake libtool intel-media-va-driver-non-free vainfo
cd libva
./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make
make install
ldconfig
cd ..