WASI_SDK_VERSION ?= 19
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(ROOT_DIR)../../Makefile.helpers

.PHONY: libuuid-builder
LIBUUID_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/libuuid-builder:wasi-$(WASI_SDK_VERSION)
libuuid-builder:
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
	@$(call build_in_container,$(LIBUUID_BUILDER_NAME),libs/uuid/$@)

.PHONY: clean
clean:
	rm -rf build-output build-staging
