# This Makefile contains the main targets for all supported language runtimes

include Makefile.helpers

.PHONY: php/php-*
php/php-*:
	make -C php $(subst php/php-,php-,$@)

.PHONY: php/php-8.2.6-slim
php/php-8.2.6-slim:
	WLR_BUILD_FLAVOR=slim \
	make -C php php-8.2.6

.PHONY: php/wasmedge-php-8.2.0
php/php-8.2.0-wasmedge:
	WLR_BUILD_FLAVOR=wasmedge \
	make -C php php-8.2.0

.PHONY: php/php-8.2.6-wasmedge
php/php-8.2.6-wasmedge:
	WLR_BUILD_FLAVOR=wasmedge \
	make -C php php-8.2.6

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
	WLR_BUILD_FLAVOR=wasmedge \
	make -C python $(subst python/wasmedge-,,$@)

.PHONY: python/aio-v3.11.1
python/aio-v3.11.1:
	WLR_BUILD_FLAVOR=aio \
	make -C python $(subst python/aio-,,$@)

.PHONY: python/aio-wasmedge-v3.11.1
python/aio-wasmedge-v3.11.1:
	WLR_BUILD_FLAVOR=aio-wasmedge \
	make -C python $(subst python/aio-wasmedge-,,$@)

.PHONY: oci-python-3.11.1
oci-python-3.11.1: python/v3.11.1
	docker build \
	    --platform wasm32/wasi \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=python/v3.11.1 \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.1 \
		-f images/python/Dockerfile \
		build-output

.PHONY: oci-python-3.11.1-wasmedge
oci-python-3.11.1-wasmedge: python/wasmedge-v3.11.1
	docker build \
	    --platform wasm32/wasi \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI+WasmEdge, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=python/v3.11.1-wasmedge \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.1-wasmedge \
		-f images/python/Dockerfile \
		build-output

.PHONY: python/wasmedge-v3.11.4
python/wasmedge-v3.11.4:
	WLR_BUILD_FLAVOR=wasmedge \
	make -C python $(subst python/wasmedge-,,$@)

.PHONY: python/aio-v3.11.4
python/aio-v3.11.4:
	WLR_BUILD_FLAVOR=aio \
	make -C python $(subst python/aio-,,$@)

.PHONY: python/aio-wasmedge-v3.11.4
python/aio-wasmedge-v3.11.4:
	WLR_BUILD_FLAVOR=aio-wasmedge \
	make -C python $(subst python/aio-wasmedge-,,$@)

.PHONY: oci-python-3.11.4
oci-python-3.11.4: python/v3.11.4
	docker build \
	    --platform wasi/wasm32 \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=python/v3.11.4 \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.4 \
		-f images/python/Dockerfile \
		build-output

.PHONY: oci-python-3.11.4-wasmedge
oci-python-3.11.3-wasmedge: python/wasmedge-v3.11.4
	docker build \
	    --platform wasi/wasm32 \
		--build-arg NAME=python-wasm \
		--build-arg SUMMARY="CPython built for WASI+WasmEdge, by Wasm Labs" \
		--build-arg ARTIFACTS_BASE_DIR=python/v3.11.4-wasmedge \
		--build-arg PYTHON_BINARY=python.wasm \
		-t ghcr.io/vmware-labs/python-wasm:3.11.4-wasmedge \
		-f images/python/Dockerfile \
		build-output

LIBS := \
	bzip2 \
	icu \
	libjpeg \
	libpng \
	libxml2 \
	libuuid \
	oniguruma \
	sqlite \
	zlib

$(foreach _,${LIBS},$(eval $(call create_external_lib_sub_targets,$_)))

LOCAL_LIBS := \
	wasmedge_sock \
	bundle_wlr

$(foreach _,${LOCAL_LIBS},$(eval $(call create_local_lib_sub_targets,$_)))

.PHONY: clean
clean:
	make -C php clean
	make -C ruby clean
	make -C python clean
	make -C libs clean
