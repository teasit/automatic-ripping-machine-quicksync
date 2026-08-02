#!/bin/bash
# https://github.com/intel/libvpl/blob/main/INSTALL.md
cd ./libvpl
export VPL_INSTALL_DIR=`pwd`/../_vplinstall
rm -rf _build
. ./script/bootstrap
cmake -B _build -DCMAKE_INSTALL_PREFIX=$VPL_INSTALL_DIR
cmake --build _build
cmake --install _build
cd ..