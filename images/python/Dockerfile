FROM scratch
ARG BUILD_OUTPUT_BASE=build-output
ARG PYTHON_TAG=v3.11.1
ARG PYTHON_BINARY=python.wasm
COPY ${BUILD_OUTPUT_BASE}/python/${PYTHON_TAG}/bin/${PYTHON_BINARY} /python.wasm
COPY ${BUILD_OUTPUT_BASE}/python/${PYTHON_TAG}/usr/ /usr

ENTRYPOINT [ "python.wasm" ]
