ARG WASI_SDK_VERSION
FROM ghcr.io/vmware-labs/wasi-builder:${WASI_SDK_VERSION}
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
      ruby \
      bison \
      gperf
ADD . /wlr/ruby
