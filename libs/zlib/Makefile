WASI_SDK_VERSION ?= 19
# NOTE - the default python build is failing with wasi-sdk-19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include ../../Makefile.builders

.PHONY: zlib-builder
WASI_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/wasi-builder:$(WASI_SDK_VERSION)
ZLIB_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/zlib-builder:wasi-$(WASI_SDK_VERSION)
zlib-builder: wasi-builder-$(WASI_SDK_VERSION)
	(! docker image inspect $(ZLIB_BUILDER_NAME) 1>/dev/null 2>&1 || \
		test -z "$(keep-containers)" ) && \
	(docker image rm $(ZLIB_BUILDER_NAME) || true) && \
	docker tag \
		`docker images -q $(WASI_BUILDER_NAME)` \
		$(ZLIB_BUILDER_NAME) \
	|| echo "Reusing existing $(ZLIB_BUILDER_NAME)"

.PHONY: v*
v*: zlib-builder
	mkdir -p build-output build-staging
	docker run \
		--platform linux/amd64 \
		--rm \
		-e WASMLABS_RUNTIME \
		-v ${ROOT_DIR}/build-output:/wlr/build-output \
		-v ${ROOT_DIR}/build-staging:/wlr/build-staging \
		-v $(ROOT_DIR):/wlr/libs/zlib \
		$(ZLIB_BUILDER_NAME) \
		./wl-make.sh libs/zlib/$@

.PHONY: clean
clean:
	rm -rf build-output build-staging
