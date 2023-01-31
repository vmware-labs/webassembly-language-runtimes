WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../Makefile.builders

.PHONY: ruby-builder
RUBY_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/ruby-builder:wasi-$(WASI_SDK_VERSION)
ruby-builder: wasi-builder-$(WASI_SDK_VERSION)
	@(! docker image inspect $(RUBY_BUILDER_NAME) 1>/dev/null 2>&1 || \
		test -z "$(keep-containers)" ) && \
	docker build \
		--platform linux/amd64 \
		-f $(ROOT_DIR)/Dockerfile \
		--build-arg WASI_SDK_VERSION=$(WASI_SDK_VERSION) \
		-t $(RUBY_BUILDER_NAME) \
		$(ROOT_DIR) \
	|| echo "Reusing existing $(RUBY_BUILDER_NAME)"

.PHONY: v*
v*: ruby-builder
	mkdir -p build-output build-staging
	docker run \
		--platform linux/amd64 \
		--rm \
		-e WASMLABS_RUNTIME \
		-e WASMLABS_TAG=v3_2_0 \
		-v $(ROOT_DIR)/build-output:/wlr/build-output \
		-v $(ROOT_DIR)/build-staging:/wlr/build-staging \
		-v $(ROOT_DIR)../libs:/wlr/libs \
		-v $(ROOT_DIR):/wlr/ruby \
		$(RUBY_BUILDER_NAME) \
		./wl-make.sh ruby/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
