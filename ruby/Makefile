WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(ROOT_DIR)../Makefile.helpers

.PHONY: ruby-builder
RUBY_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/ruby-builder:wasi-$(WASI_SDK_VERSION)
ruby-builder:
	@$(call make_builder_image,$(RUBY_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: push-ruby-builder
push-ruby-builder:
	@$(call push_container_image,$(RUBY_BUILDER_NAME))

.PHONY: v*
v*:
	@$(call build_in_container,$(RUBY_BUILDER_NAME),ruby/$@)

.PHONY: clean
clean:
	rm -rf build-output build-staging
