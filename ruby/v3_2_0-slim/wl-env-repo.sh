#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_BRANCH
    unset WASMLABS_ENV_NAME
    unset WASMLABS_PACKAGE_VERSION
    unset WASMLABS_PACKAGE_NAME
    return
fi

export WASMLABS_REPO=https://github.com/ruby/ruby.git
export WASMLABS_REPO_BRANCH=v3_2_0
export WASMLABS_ENV_NAME=ruby/v3_2_0
export WASMLABS_PACKAGE_VERSION=3.2.0
export WASMLABS_PACKAGE_NAME=ruby
