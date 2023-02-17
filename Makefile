# This Makefile contains the main targets for all supported language runtimes

.PHONY: php/php-*
php/php-*:
	make -C php $(subst php/php-,php-,$@)

.PHONY: php/master
php/master:
	make -C php master

.PHONY: ruby/v*
ruby/v*:
	make -C ruby $(subst ruby/,,$@)

.PHONY: python/v*
python/v*:
	make -C python $(subst python/,,$@)

.PHONY: python/wasmedge-v3.11.1
python/wasmedge-v3.11.1:
	WASMLABS_BUILD_FLAVOR=wasmedge \
	make -C python $(subst python/wasmedge-,,$@)

.PHONY: python/aio-v3.11.1
python/aio-v3.11.1:
	WASMLABS_BUILD_FLAVOR=aio \
	make -C python $(subst python/aio-,,$@)

.PHONY: python/aio-wasmedge-v3.11.1
python/aio-wasmedge-v3.11.1:
	WASMLABS_BUILD_FLAVOR=aio-wasmedge \
	make -C python $(subst python/aio-wasmedge-,,$@)

.PHONY: oci-python-3.11.1
oci-python-3.11.1: python/v3.11.1
	docker build \
	    --platform wasm32/wasi \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI+Wasmedge, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=build-output/python/v3.11.1 \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.1 \
		-f images/python/Dockerfile \
		.

.PHONY: oci-python-3.11.1-wasmedge
oci-python-3.11.1-wasmedge: python/wasmedge-v3.11.1
	docker build \
	    --platform wasm32/wasi \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI+WasmEdge, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=build-output/python/v3.11.1-wasmedge \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
		-f images/python/Dockerfile \
		.

.PHONY: libs/uuid/*
libs/uuid/*:
	make -C libs/uuid $(subst libs/uuid/,,$@)

.PHONY: libs/zlib/*
libs/zlib/*:
	make -C libs/zlib $(subst libs/zlib/,,$@)

.PHONY: clean
clean:
	make -C php clean
	make -C ruby clean
	make -C python clean
	make -C libs clean
