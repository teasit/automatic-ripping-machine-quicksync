FROM automaticrippingmachine/automatic-ripping-machine:2.24.3

USER root

WORKDIR /opt/automatic-ripping-machine-quicksync

COPY scripts/ ./scripts/
COPY libva/ ./libva/
COPY libvpl/ ./libvpl/
COPY vpl-gpu-rt/ ./vpl-gpu-rt/

RUN chmod +x ./scripts/*.sh

# Installs LIBVA as it is a dependency for Intel VPL.
RUN ./scripts/install_intel_libva.sh

# Installs the dispatcher and library headers.
RUN ./scripts/install_intel_vpl_lib.sh

# Installs the implementation of the library.
RUN ./scripts/install_intel_vpl_gpu.sh

USER arm

WORKDIR /home/arm