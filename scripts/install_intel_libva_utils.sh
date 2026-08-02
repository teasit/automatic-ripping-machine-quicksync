#!/bin/bash
set -euo pipefail

# https://github.com/intel/libva-utils#build-and-install-libva-utils
cd libva-utils
./autogen.sh
make -j$(nproc)
make install
cd ..