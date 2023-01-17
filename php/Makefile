WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../Makefile.builders

.PHONY: php-builder
php-builder: wasi-builder-$(WASI_SDK_VERSION)
	docker build -f ${ROOT_DIR}/Dockerfile --build-arg WASI_SDK_VERSION=$(WASI_SDK_VERSION) -t ghcr.io/vmware-labs/php-builder:wasi-$(WASI_SDK_VERSION) ${ROOT_DIR}

.PHONY: php-*
php-*: php-builder
	mkdir -p build-output build-staging
	docker run --rm -e WASMLABS_RUNTIME -v ${ROOT_DIR}/build-output:/wlr/build-output -v ${ROOT_DIR}/build-staging:/wlr/build-staging ghcr.io/vmware-labs/php-builder:wasi-${WASI_SDK_VERSION} ./wl-make.sh php/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
