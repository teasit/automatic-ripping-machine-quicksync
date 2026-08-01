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

# Ensure the VPL runtime libraries are discoverable by the dynamic linker.
RUN echo /opt/automatic-ripping-machine-quicksync/_vplinstall/lib > /etc/ld.so.conf.d/libvpl.conf && ldconfig
ENV LD_LIBRARY_PATH=/opt/automatic-ripping-machine-quicksync/_vplinstall/lib:/usr/lib/x86_64-linux-gnu

USER arm

WORKDIR /home/arm