WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(ROOT_DIR)../Makefile.helpers

.PHONY: php-builder
PHP_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/php-builder:wasi-$(WASI_SDK_VERSION)
php-builder:
	@$(call make_builder_image,$(PHP_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: push-php-builder
push-php-builder:
	@$(call push_container_image,$(PHP_BUILDER_NAME))

.PHONY: php-*
php-*:
	@$(call build_in_container,$(PHP_BUILDER_NAME),php/$@)

.PHONY: master
master:
	@$(call build_in_container,$(PHP_BUILDER_NAME),php/$@)

.PHONY: clean
clean:
	rm -rf build-output build-staging
