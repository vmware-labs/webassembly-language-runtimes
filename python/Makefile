ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)..

include $(REPO_ROOT)/Makefile.helpers

.PHONY: python-builder
PYTHON_BUILDER_NAME := ghcr.io/vmware-labs/wasmlabs/python-builder:wasi-$(WASI_SDK_VERSION)
python-builder:
	@$(call make_builder_image,$(PYTHON_BUILDER_NAME),$(ROOT_DIR),$(WASI_SDK_VERSION))

.PHONY: push-python-builder
push-python-builder:
	@$(call push_container_image,$(PYTHON_BUILDER_NAME))

.PHONY: v*
v*:
	@$(call build_in_container,$(PYTHON_BUILDER_NAME),$(REPO_ROOT),python/$@)

.PHONY: clean
clean:
	rm -rf $(REPO_ROOT)/build-output/python $(REPO_ROOT)/build-staging/python
