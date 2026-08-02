#!/bin/bash
set -euo pipefail

# https://github.com/intel/libvpl/blob/main/INSTALL.md
cd ./libvpl
rm -rf _build
. ./script/bootstrap
cmake -B _build -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build _build
cmake --install _build
cd ..