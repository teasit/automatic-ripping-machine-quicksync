# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A derived Docker image of [Automatic Ripping Machine (ARM)](https://github.com/automatic-ripping-machine/automatic-ripping-machine) that adds Intel Quick Sync (QSV) hardware encoding. The official ARM image is Ubuntu 22.04, whose libva is too old for Intel oneVPL, so the `Dockerfile` takes `automaticrippingmachine/automatic-ripping-machine:latest`, runs `do-release-upgrade` to Ubuntu 24.04 inside the image, installs the Intel media stack, and then re-runs ARM's own install steps against the new OS. Published as `ghcr.io/teasit/automatic-ripping-machine-quicksync`.

There is no test suite, linter, or local build tooling. A local build is `docker build -t arm-qsv .` (slow and large, because of the release upgrade). Check QSV inside a running container with `vainfo` and `HandBrakeCLI-qsv --help`.

## Dockerfile structure (order matters)

1. **Release upgrade:** `Dpkg::Options --force-confdef/--force-confold` is written to apt config first. Without it, dpkg conffile prompts block the non-interactive `do-release-upgrade`.
2. **Intel stack:** enables the universe and multiverse repositories, then installs `intel-media-va-driver-non-free`, `libvpl2`, `libmfx-gen1.2`, the libva packages and `vainfo`.
3. **Reapplying ARM setup:** these steps depend on files that already ship inside the base image at `/opt/arm`, not files in this repo's build context. They are the custom udev init script, the `arm-dependencies` git submodule (needed for `requirements.txt`), `pip3 install --break-system-packages` (Ubuntu 24.04 Python), `/install_mkv_hb_deps.sh` and `/install_handbrake.sh`. They mirror the upstream ARM and arm-dependencies Dockerfiles, which the comments link to.
4. **`HandBrakeCLI-qsv` wrapper:** HandBrake passes the QSV adapter index `"0"` to FFmpeg as a relative VAAPI device path. The wrapper `cd`s into `/opt/hbdev`, where `0` is a symlink to `/dev/dri/renderD128`, then execs HandBrakeCLI. The wrapper is opt-in: users enable it with `HANDBRAKE_CLI: HandBrakeCLI-qsv` in `arm.yaml`. The image is used by others, so plain `HandBrakeCLI` must stay unchanged.
5. `/install_makemkv.sh` is commented out on purpose, because makemkv.com is unreliable during builds.

## CI (`.github/workflows/`)

- `docker-publish.yml` builds and pushes on pushes to `main` that touch `Dockerfile`. It tags `latest`, the branch name and `sha-*`.
- `nightly-rebuild.yml` runs daily. It uses `skopeo` to compare the upstream base image digest with the `org.opencontainers.image.base.digest` label on our `:latest`, and rebuilds with `no-cache` only when the two differ. It also runs on pushes that touch `Dockerfile`, `presets/` or `scripts/`, and on manual dispatch with `force`. It writes the base-digest label, so if that label is removed, every nightly run will rebuild.
- Both workflows publish `:latest`, so a `Dockerfile` push triggers both.

## `presets/` and `scripts/`

The `Dockerfile` does not `COPY` these into the image. They are meant to be used alongside a running ARM container.

- `presets/*.json` are HandBrake preset exports. The QSV variants use `qsv_h265`, and the MKV variants use software `x265_10bit`. ARM's `HB_PRESET_*` settings refer to presets by name.
- `scripts/batch_encode_rips.py` re-encodes a directory tree of ripped MKVs. It runs inside the container and needs PyYAML. It reads `/home/arm/config/arm.yaml` for `HANDBRAKE_CLI`, `HB_PRESET_BD` and `HB_ARGS_BD` (split with `shlex`, no shell), and keeps the relative paths in the output directory. It prints a tree, asks for confirmation (and a second confirmation if outputs would be overwritten) unless `-y` is passed, and stops at the first HandBrake failure. `--ignore-extras` skips MKVs under folders named in `EXTRAS_DIRS`.
  Usage: `python3 scripts/batch_encode_rips.py <input_dir> <output_dir> [-y] [--ignore-extras]`
