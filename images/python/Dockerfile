FROM scratch

ARG NAME
ARG SUMMARY
LABEL description="${SUMMARY}" \
      app.kubernetes.io/name="${NAME}" \
      org.opencontainers.image.title="${NAME}" \
      org.opencontainers.image.vendor="wasmlabs.dev" \
      org.opencontainers.image.description="${SUMMARY}" \
      org.opencontainers.image.source="https://github.com/vmware-labs/webassembly-language-runtimes" \
      org.opencontainers.artifact.description="${SUMMARY}"

ARG ARTIFACTS_BASE_DIR
ARG PYTHON_BINARY
COPY ${ARTIFACTS_BASE_DIR}/bin/${PYTHON_BINARY} /python.wasm
COPY ${ARTIFACTS_BASE_DIR}/usr/ /usr

ENTRYPOINT [ "python.wasm" ]
