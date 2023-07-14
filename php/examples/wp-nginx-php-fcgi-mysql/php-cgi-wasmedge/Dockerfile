# Downloads php-cgi.wasm and optimized it with wasmedgec for the current platform
FROM --platform=$BUILDPLATFORM debian:buster-slim AS builder

# curl - to download stuff
# git, python3 - to install wasmedge
RUN apt update && \
      DEBIAN_FRONTEND=noninteractive apt install -y \
        curl \
        git \
        python3

RUN mkdir /opt/work
WORKDIR /opt/work

# Download php-cgi-wasmedge.wasm
RUN curl -L -o php-cgi-wasmedge.wasm https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/php%2F8.2.6%2B20230714-11be424/php-8.2.6-wasmedge.wasm

# Install wasmedgec
RUN curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash

# Just doing AOT without optimizing as the binary is already optimized
RUN /root/.wasmedge/bin/wasmedgec --optimize 0 /opt/work/php-cgi-wasmedge.wasm php-cgi-wasmedge-aot.wasm



FROM scratch
ENTRYPOINT [ "php-cgi-wasmedge.wasm", "-b", "0.0.0.0:9000", "-d", "ignore_user_abort=On"]
COPY --link --from=builder /opt/work/php-cgi-wasmedge-aot.wasm /php-cgi-wasmedge.wasm
