FROM automaticrippingmachine/automatic-ripping-machine:2.24.3

# Base image is Ubuntu 22.04 which is capped at libva 1.14.0, which is too old for the Intel VPL library.
# Therefore we upgrade the base image as suggested here:
#   https://github.com/automatic-ripping-machine/automatic-ripping-machine/issues/1522#issuecomment-3331943958
# DistUpgradeViewNonInteractive only silences do-release-upgrade's own prompts. Conffile
# prompts (e.g. "sshd_config has been locally modified") come from dpkg itself and need
# Dpkg::Options set explicitly, otherwise dpkg blocks waiting on stdin even in this frontend.
RUN echo 'Dpkg::Options {"--force-confdef";"--force-confold";}' > /etc/apt/apt.conf.d/local
RUN DEBIAN_FRONTEND=noninteractive apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y update-manager-core && \
    DEBIAN_FRONTEND=noninteractive apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive do-release-upgrade -f DistUpgradeViewNonInteractive
RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Intel Quick Sync / VA-API / oneVPL
# ---------------------------------------------------------------------------
# Enable Ubuntu repositories required for Intel QSV / oneVPL.
# intel-media-va-driver-non-free is in multiverse;
# libvpl2, vainfo, etc. are in universe.
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y universe && \
    add-apt-repository -y multiverse
# ARM's original Ubuntu 22.04 image does not contain the Intel media stack.
# Ubuntu 24.04 provides the modern Intel iHD driver and oneVPL runtime.
# - intel-media-va-driver-non-free: Intel iHD VA-API driver
# - vainfo: useful for validating the VA-API installation
# - libva-drm2: DRM backend used with /dev/dri/renderD128
# - libvpl2: Intel oneVPL runtime used by modern QSV applications
# - libmfx-gen1.2: Intel oneVPL Gen1.2 runtime
# See also: https://dgpu-docs.intel.com/installation-guides/installing-packages-from-the-intel-ppa.html
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    intel-media-va-driver-non-free \
    libva2 \
    libva-drm2 \
    libva-x11-2 \
    libva-wayland2 \
    libmfx-gen1.2 \
    vainfo \
    libvpl2 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/arm

# The file ships inside the base image, so it is copied in-image rather than from the build context.
# https://github.com/automatic-ripping-machine/automatic-ripping-machine/blob/39fc1e36a2bcef67a63244c1ec411a54f16e773c/Dockerfile#L58
RUN cp /opt/arm/scripts/docker/custom_udev /etc/init.d/udev && \
    chmod +x /etc/init.d/udev && \
    chmod +x /etc/my_init.d/*.sh

# Initialize arm-dependencies submodule because it contains pip requirements
# If this is not done, pip3 install (next step) fails.
RUN git submodule update --init --depth 1 ./arm-dependencies
# Python environment belongs to Ubuntu 24.04 now: reinstall ARM dependencies
RUN pip3 install --break-system-packages \
    --ignore-installed \
    --prefer-binary \
    -r /opt/arm/requirements.txt

# Reinstall the ARM dependencies and HandBrakeCLI with Intel QuickSync support using ARM script.
# https://github.com/automatic-ripping-machine/arm-dependencies/blob/main/Dockerfile
RUN /install_mkv_hb_deps.sh
RUN /install_handbrake.sh

# Reinstalling MakeMKV often fails due to instable makemkv.com dependency.
# Also seems not required, so it is commented out.
# RUN /install_makemkv.sh
