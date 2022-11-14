ARG WASI_SDK_VERSION=16
FROM ghcr.io/vmware-labs/wasi-builder:${WASI_SDK_VERSION}
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      bison \
      re2c \
      libsqlite3-dev \
      tcl
ADD . /wlr/php
