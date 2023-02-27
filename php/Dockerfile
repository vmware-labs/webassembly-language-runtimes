ARG WASI_SDK_VERSION
FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      bison \
      re2c