#!/bin/bash
# https://github.com/intel/libvpl/blob/main/INSTALL.md
cd ./libvpl
export VPL_INSTALL_DIR=`pwd`/../_vplinstall

# Install only the dependencies needed to build libvpl.
# Avoid running libvpl/script/bootstrap here because it reinstalls distro
# libva packages and overwrites the custom libva runtime installed earlier.
apt-get update
apt-get install -y --no-install-recommends \
	build-essential \
	cmake \
	pkg-config \
	libdrm-dev \
	libx11-dev \
	libx11-xcb-dev \
	libxcb-present-dev \
	libxcb-dri3-dev \
	libwayland-dev \
	wayland-protocols

rm -rf _build
cmake -B _build -DCMAKE_INSTALL_PREFIX=$VPL_INSTALL_DIR
cmake --build _build
cmake --install _build
mkdir -p /etc/ld.so.conf.d
printf '%s\n' "$VPL_INSTALL_DIR/lib" > /etc/ld.so.conf.d/libvpl.conf
ldconfig
cd ..
