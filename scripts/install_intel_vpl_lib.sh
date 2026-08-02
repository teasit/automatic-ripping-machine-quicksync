#!/bin/bash
# https://github.com/intel/libvpl/blob/main/INSTALL.md
cd ./libvpl
export VPL_INSTALL_DIR=`pwd`/../_vplinstall
. ./script/bootstrap
rm -rf _build
cmake -B _build -DCMAKE_INSTALL_PREFIX=$VPL_INSTALL_DIR
cmake --build _build
cmake --install _build
mkdir -p /etc/ld.so.conf.d
printf '%s\n' "$VPL_INSTALL_DIR/lib" > /etc/ld.so.conf.d/libvpl.conf
ldconfig
cd ..
