WASI_SDK_VERSION ?= 19.0

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)../..

default_target: all
.PHONY : default_target

include $(REPO_ROOT)/Makefile.helpers

$(eval $(call create_default_local_lib_targets,$(REPO_ROOT),bundle_wlr,$(WASI_SDK_VERSION)))
