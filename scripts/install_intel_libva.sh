#!/bin/bash
# Install a distro-consistent VA-API stack so libva, its helper libraries,
# and Intel's media driver use the same ABI.
apt-get update
apt-get install -y \
	libva-dev \
	libva2 \
	libva-drm2 \
	libva-x11-2 \
	libva-wayland2 \
	intel-media-va-driver-non-free \
	libdrm-dev \
	vainfo
ldconfig