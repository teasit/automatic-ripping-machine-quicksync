FROM automaticrippingmachine/automatic-ripping-machine:2.24.3

RUN apt update -y && apt upgrade -y

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig

WORKDIR /opt/automatic-ripping-machine-quicksync

COPY scripts/ ./scripts/
COPY libva/ ./libva/
COPY libva-utils/ ./libva-utils/
COPY gmmlib/ ./gmmlib/
COPY media-driver/ ./media-driver/
COPY libvpl/ ./libvpl/
COPY vpl-gpu-rt/ ./vpl-gpu-rt/

# Ensure the scripts are executable.
RUN chmod +x ./scripts/*.sh

# Installs LIBVA as it is a dependency for Intel VPL.
# Installation directory: /usr/local/lib/x86_64-linux-gnu
RUN ./scripts/install_intel_libva.sh

# Installs LIBVA-UTILS (enables vainfo command).
# This is probably not required, but useful for debugging.
RUN ./scripts/install_intel_libva_utils.sh

# Install gmmlib (required by Intel Media Driver for VAAPI).
RUN ./scripts/install_intel_gmmlib.sh

# Install Intel Media Driver for VAAPI.
RUN ./scripts/install_intel_media_driver.sh

# Installs the dispatcher and library headers.
RUN ./scripts/install_intel_vpl_lib.sh

# Installs the implementation of the library.
RUN ./scripts/install_intel_vpl_gpu.sh

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib/x86_64-linux-gnu
ENV LIBVA_DRIVERS_PATH=/usr/local/lib/dri
ENV LIBVA_DRIVER_NAME=iHD

# Show the runtime libva version that HandBrakeCLI will resolve against.
RUN pkg-config --modversion libva && ldconfig
