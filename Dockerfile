FROM automaticrippingmachine/automatic-ripping-machine:2.24.3

RUN apt update -y && apt upgrade -y

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
# Installation directory: /usr/lib/x86_64-linux-gnu
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

# Installs the VPL runtime libraries to a location discoverable by the dynamic linker.
RUN ldconfig

# Ensure the VPL runtime libraries are discoverable by the dynamic linker.
RUN echo /opt/automatic-ripping-machine-quicksync/_vplinstall/lib > /etc/ld.so.conf.d/libvpl.conf && ldconfig
ENV LD_LIBRARY_PATH=/opt/automatic-ripping-machine-quicksync/_vplinstall/lib:/opt/intel/mediasdk/lib:/usr/lib/x86_64-linux-gnu
ENV ONEVPL_PRIORITY_PATH=/opt/intel/mediasdk/lib

WORKDIR /home/arm