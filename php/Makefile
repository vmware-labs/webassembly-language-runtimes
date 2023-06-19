ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)..

include $(REPO_ROOT)/Makefile.helpers

.PHONY: php-builder
PHP_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/php-builder:wasi-$(WASI_SDK_VERSION)
php-builder:
	@$(call make_builder_image,$(PHP_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: update-php-builder
update-php-builder: php-builder
	@$(call push_container_image,$(PHP_BUILDER_NAME))

.PHONY: php-*
php-*:
	@$(call build_in_container,$(PHP_BUILDER_NAME),$(REPO_ROOT),php/$@)

.PHONY: master
master:
	@$(call build_in_container,$(PHP_BUILDER_NAME),$(REPO_ROOT),php/$@)

.PHONY: clean
clean:
	rm -rf $(REPO_ROOT)/build-output/php $(REPO_ROOT)/build-staging/php
