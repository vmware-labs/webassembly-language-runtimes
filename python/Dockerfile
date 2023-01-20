ARG WASI_SDK_VERSION
FROM wasi-builder:${WASI_SDK_VERSION}

# If more capabilities are required from the build-erpython, consult this
# github workflow configuration for a list of possible dependencies -
# https://github.com/python/cpython/blob/main/.github/workflows/posix-deps-apt.sh
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      tcl \
      uuid-dev \
      zlib1g-dev

ADD . /wlr/php
