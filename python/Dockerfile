ARG WASI_SDK_VERSION
ARG PY_VERSIONS="3.12.0 3.11.4"
ARG PY_DEFAULT_VERSION=3.12.0

FROM ghcr.io/vmware-labs/wasmlabs/wasi-builder:${WASI_SDK_VERSION}
ARG PY_VERSIONS
ARG PY_DEFAULT_VERSION
# If more capabilities are required from the python-builder, consult this
# github workflow configuration for a list of possible dependencies -
# https://github.com/python/cpython/blob/main/.github/workflows/posix-deps-apt.sh
RUN DEBIAN_FRONTEND=noninteractive apt update && \
      apt install -y --no-install-recommends \
      libssl-dev \
      tcl \
      zlib1g-dev

ENV HOME="/root"
WORKDIR ${HOME}
RUN git clone --depth=1 https://github.com/pyenv/pyenv.git .pyenv
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

RUN pyenv install ${PY_VERSIONS}
RUN pyenv global ${PY_DEFAULT_VERSION}

WORKDIR /wlr
