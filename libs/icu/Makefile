ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)../..

include $(REPO_ROOT)/Makefile.helpers

$(eval $(call create_default_external_lib_targets,$(REPO_ROOT),icu,$(WASI_SDK_VERSION)))
