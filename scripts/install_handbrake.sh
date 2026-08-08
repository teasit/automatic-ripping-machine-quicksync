#!/bin/bash
set -euo pipefail

# https://handbrake.fr/docs/en/latest/developer/build-linux.html
# --disable-gtk --> Only CLI is built, no GUI.
# --enable-qsv --> Enables Intel QuickSync Video support.
cd HandBrake
./configure --disable-gtk --enable-qsv --launch-jobs=$(nproc) --launch
make --directory=build install
cd ..