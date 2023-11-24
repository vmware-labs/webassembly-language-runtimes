ARG WASI_SDK_VERSION
ARG PY_VERSION=3.12.0
ARG PY_SHORT_VERSION=3.12

FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION} as build-host-python
ARG PY_VERSION
ARG PY_SHORT_VERSION
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      zlib1g-dev
WORKDIR /tmp
RUN wget -c https://www.python.org/ftp/python/${PY_VERSION}/Python-${PY_VERSION}.tar.xz && tar -Jxf Python-${PY_VERSION}.tar.xz
WORKDIR /tmp/Python-${PY_VERSION}
RUN ./configure --enable-optimizations --prefix=/opt/python${PY_SHORT_VERSION}
RUN make -j4 && make install

FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}
ARG PY_SHORT_VERSION
# If more capabilities are required from the python-builder, consult this
# github workflow configuration for a list of possible dependencies -
# https://github.com/python/cpython/blob/main/.github/workflows/posix-deps-apt.sh
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      tcl

COPY --from=build-host-python /opt/python${PY_SHORT_VERSION}/ /opt/python${PY_SHORT_VERSION}/
RUN update-alternatives --install /usr/bin/python3 python3 /opt/python${PY_SHORT_VERSION}/bin/python${PY_SHORT_VERSION} 110
RUN update-alternatives --install /usr/bin/python${PY_SHORT_VERSION} python${PY_SHORT_VERSION} /opt/python${PY_SHORT_VERSION}/bin/python${PY_SHORT_VERSION} 110
