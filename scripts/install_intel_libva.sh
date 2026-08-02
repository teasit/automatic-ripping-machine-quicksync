#!/bin/bash
# Build a newer, self-consistent VA-API stack so HandBrake's QSV encoder path
# is not limited by Ubuntu Jammy's older libva runtime.
apt-get update
apt-get install -y \
	automake \
	cmake \
	intel-media-va-driver-non-free \
	libdrm-dev \
	libtool \
	libwayland-dev \
	libx11-dev \
	libx11-xcb-dev \
	libxcb-dri3-dev \
	libxcb-present-dev \
	libxcb-randr0-dev \
	libxcb-shape0-dev \
	libxcb-sync-dev \
	libxcb-xfixes0-dev \
	meson \
	pkg-config \
	vainfo \
	wayland-protocols

cd libva
[ -f Makefile ] && make distclean || true
./autogen.sh --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make
make install
ldconfig
cd ..