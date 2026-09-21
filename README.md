# Automatic Ripping Machine (ARM) with Intel Quicksync (QSV) Support

As described [here](https://github.com/automatic-ripping-machine/automatic-ripping-machine/wiki/Hardware-Transcode-Intel-QSV), the prebuilt docker image of ARM does not ship with the latest Intel VPL stack to support hardware-encoding of ripped MKVs. They cannot easily be installed due to the base image being based on Ubuntu 22. With Ubuntu 24 the Intel VPL stack is easily installed. The goal of this custom Dockerfile is to reuse the official Dockerfile of ARM, update Ubuntu OS and reapply all required ARM installations.

The result is a QSV-capable ARM docker image.