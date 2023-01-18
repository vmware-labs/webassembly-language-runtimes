WASI_SDK_VERSION ?= 16
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../Makefile.builders

.PHONY: python-builder
python-builder: wasi-builder-16
	docker build -f ${ROOT_DIR}/Dockerfile --build-arg WASI_SDK_VERSION=$(WASI_SDK_VERSION) -t ghcr.io/vmware-labs/python-builder:wasi-$(WASI_SDK_VERSION) ${ROOT_DIR}

.PHONY: v*
v*: python-builder
	mkdir -p build-output build-staging
	docker run --rm -e WASMLABS_RUNTIME -v ${ROOT_DIR}/build-output:/wlr/build-output -v ${ROOT_DIR}/build-staging:/wlr/build-staging ghcr.io/vmware-labs/python-builder:wasi-${WASI_SDK_VERSION} ./wl-make.sh python/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
