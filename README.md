# Automatic Ripping Machine (ARM) with Intel Quicksync (QSV) Support

As described [here](https://github.com/automatic-ripping-machine/automatic-ripping-machine/wiki/Hardware-Transcode-Intel-QSV), the prebuilt docker image of ARM does not ship with the latest Intel VPL stack to support hardware-encoding of ripped MKVs. They cannot easily be installed due to the base image being based on Ubuntu 22. With Ubuntu 24 the Intel VPL stack is easily installed. The goal of this custom Dockerfile is to reuse the official Dockerfile of ARM, update Ubuntu OS and reapply all required ARM installations.

The result is a QSV-capable ARM docker image.

The docker compose should look something like this...

```yaml
services:
  arm:
    image: ghcr.io/teasit/automatic-ripping-machine-quicksync:latest
    container_name: arm
    privileged: true
    restart: always
    environment:
      ARM_UID: "1001"
      ARM_GID: "100"
      TZ: Europe/Berlin
    ports:
      - "8080:8080"
    volumes:
      - /mnt/user/appdata/arm:/home/arm
      - /mnt/user/appdata/arm/logs:/home/arm/logs
      - /mnt/user/arm/media:/home/arm/media
      - /mnt/user/appdata/arm/config:/etc/arm/config
    devices:
      - /dev/sr0:/dev/sr0
      - /dev/sg0:/dev/sg0
      - /dev/dri:/dev/dri
```
