ARG WASI_SDK_VERSION
FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      libtool-bin \
      bison \
      re2c \
      libsqlite3-dev \
      tcl
ADD . /wlr/php
