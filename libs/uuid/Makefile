WASI_SDK_VERSION ?= 19
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../../Makefile.builders

.PHONY: libuuid-builder
LIBUUID_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/libuuid-builder:wasi-$(WASI_SDK_VERSION)
libuuid-builder: wasi-builder-$(WASI_SDK_VERSION)
	@(! docker image inspect $(LIBUUID_BUILDER_NAME) 1>/dev/null 2>&1 || \
		test -z "$(keep-containers)" ) && \
	docker build \
		--platform linux/amd64 \
		-f $(ROOT_DIR)/Dockerfile \
		--build-arg WASI_SDK_VERSION=$(WASI_SDK_VERSION) \
		-t $(LIBUUID_BUILDER_NAME) \
		$(ROOT_DIR) \
	|| echo "Reusing existing $(LIBUUID_BUILDER_NAME)"

.PHONY: v*
libuuid-*: libuuid-builder
	mkdir -p build-output build-staging
	docker run \
		--platform linux/amd64 \
		--rm \
		-e WASMLABS_RUNTIME \
		-v $(ROOT_DIR)/build-output:/wlr/build-output \
		-v $(ROOT_DIR)/build-staging:/wlr/build-staging \
		-v $(ROOT_DIR):/wlr/libs/uuid \
		$(LIBUUID_BUILDER_NAME) \
		./wl-make.sh libs/uuid/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
