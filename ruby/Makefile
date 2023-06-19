ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)..

include $(REPO_ROOT)/Makefile.helpers

.PHONY: ruby-builder
RUBY_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/ruby-builder:wasi-$(WASI_SDK_VERSION)
ruby-builder:
	@$(call make_builder_image,$(RUBY_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: update-ruby-builder
update-ruby-builder: ruby-builder
	@$(call push_container_image,$(RUBY_BUILDER_NAME))

.PHONY: v*
v*:
	@$(call build_in_container,$(RUBY_BUILDER_NAME),$(REPO_ROOT),ruby/$@)

.PHONY: clean
clean:
	rm -rf $(REPO_ROOT)/build-output/ruby $(REPO_ROOT)/build-staging/ruby
