WASI_SDK_VERSION ?= 19

ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(ROOT_DIR)../..

include $(REPO_ROOT)/Makefile.helpers

$(eval $(call create_default_lib_targets,$(REPO_ROOT),libxml2,v,$(WASI_SDK_VERSION)))
