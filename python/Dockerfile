ARG WASI_SDK_VERSION

FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION} as build-host-python
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      zlib1g-dev
WORKDIR /tmp
RUN wget -c https://www.python.org/ftp/python/3.11.0/Python-3.11.0.tar.xz && tar -Jxf Python-3.11.0.tar.xz
WORKDIR /tmp/Python-3.11.0
RUN ./configure --enable-optimizations --prefix=/opt/python3.11
RUN make -j4 && make install

FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}

# If more capabilities are required from the build-erpython, consult this
# github workflow configuration for a list of possible dependencies -
# https://github.com/python/cpython/blob/main/.github/workflows/posix-deps-apt.sh
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      tcl \
      libtool \
      libtool-bin
COPY --from=build-host-python /opt/python3.11/ /opt/python3.11/
RUN update-alternatives --install /usr/bin/python3 python3 /opt/python3.11/bin/python3.11 110
RUN update-alternatives --install /usr/bin/python3.11 python3.11 /opt/python3.11/bin/python3.11 110
