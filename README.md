# Automatic Ripping Machine (ARM) with Intel Quicksync (QSV) Support

[![Nightly rebuild on base image update](https://github.com/teasit/automatic-ripping-machine-quicksync/actions/workflows/nightly-rebuild.yml/badge.svg)](https://github.com/teasit/automatic-ripping-machine-quicksync/actions/workflows/nightly-rebuild.yml)

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

## Optional: QSV hardware decoding with `HandBrakeCLI-qsv`

The image ships the normal `HandBrakeCLI` without changes. It also ships an extra wrapper, `/usr/local/bin/HandBrakeCLI-qsv`. You only need the wrapper if you want HandBrake to **decode** on the GPU (`--enable-hw-decoding qsv`). QSV *encoding* works with plain `HandBrakeCLI`.

**Why it exists:** on Linux, HandBrake passes the QSV adapter index (`"0"`) to FFmpeg as the VAAPI device. FFmpeg opens that as a *relative file path*, so hardware decoding fails, for example `--enable-hw-decoding qsv` on H.264 sources. The wrapper changes into `/opt/hbdev`, where `0` is a symlink to `/dev/dri/renderD128`, and then runs `HandBrakeCLI` with the same arguments.

To use it, set this in `arm.yaml`:

```yaml
HANDBRAKE_CLI: "HandBrakeCLI-qsv"
HB_ARGS_BD: "... --encoder qsv_h265 --enable-hw-decoding qsv"
```

Limitations:
- **Render node:** the symlink points to `/dev/dri/renderD128`. On systems with more than one GPU where the Intel iGPU is a different node, use plain `HandBrakeCLI` or create your own symlink.
- **Working directory:** the wrapper changes the working directory, so pass absolute input and output paths. ARM already does this.
- **Supported codecs:** HandBrake's QSV decoder only supports H.264, HEVC and AV1. VC-1 Blu-rays and MPEG-2 sources are still decoded in software, whichever binary you use. Software VC-1 decoding is single-threaded and was the bottleneck on an N100, at about 65 fps.

## Performance tuning (optional)

Measured on an Intel N100 (UHD Graphics, 24 EU) with HandBrake 1.11.2. The source was a 1080p H.264 Blu-ray rip, encoded to HEVC at quality 20 with the `balanced` preset and QSV decoding.

| Setup | CPU power limit (PL1) | avg fps | CPU (cores) |
|---|---|---|---|
| Default QSV encode | 6 W | 27–37 | 0.3 |
| Default QSV encode | 10–15 W | 71–76 | 0.4 |
| `lowpower=1` | 6 W | ~41 | 0.5 |
| `lowpower=1` | 10 W | 123–135 | 0.7–0.9 |

The CPU was never the bottleneck. Two other things limit throughput:

1. **The encoder engine.** By default, QSV HEVC encodes on the GPU's shader EUs, and the render engine runs at about 90%. `--encopts lowpower=1` moves encoding to the fixed-function VDEnc block, which roughly doubles throughput. At the same quality setting, quality (SSIM) was unchanged and file size was +1.4%. VDEnc HEVC needs Ice Lake or newer, so leave this option out on older CPUs. `--encopts` replaces the preset's `VideoOptionExtra`, so add any other encoder options to the same string, separated by `:`.
2. **The CPU package power limit.** Many low-power boards (N100 and similar) default to PL1 = 6 W. An idle server running other containers can already use that, so the iGPU gets throttled to about 250 MHz instead of 750 MHz. Check this with `cat /sys/class/drm/card0/gt/gt0/throttle_reason_pl1` during an encode. You can raise PL1 in the BIOS, or on the host at boot. On Unraid, add this line to `/boot/config/go`:
   ```sh
   echo 10000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw   # 10 W
   ```
   Check that your cooling can handle the higher limit.
