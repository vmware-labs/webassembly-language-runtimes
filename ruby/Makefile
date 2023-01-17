WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../Makefile.builders

.PHONY: ruby-builder
ruby-builder: wasi-builder-$(WASI_SDK_VERSION)
	docker build -f ${ROOT_DIR}/Dockerfile --build-arg WASI_SDK_VERSION=$(WASI_SDK_VERSION) -t ghcr.io/vmware-labs/ruby-builder:wasi-$(WASI_SDK_VERSION) ${ROOT_DIR}

.PHONY: v*
v*: ruby-builder
	mkdir -p build-output build-staging
	docker run --rm -e WASMLABS_RUNTIME -e WASMLABS_TAG=v3_2_0 -v ${ROOT_DIR}/build-output:/wlr/build-output -v ${ROOT_DIR}/build-staging:/wlr/build-staging ghcr.io/vmware-labs/ruby-builder:wasi-${WASI_SDK_VERSION} ./wl-make.sh ruby/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
