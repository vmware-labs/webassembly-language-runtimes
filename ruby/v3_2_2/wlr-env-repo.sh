#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WLR_REPO
    unset WLR_REPO_BRANCH
    unset WLR_ENV_NAME
    unset WLR_PACKAGE_VERSION
    unset WLR_PACKAGE_NAME
    return
fi

export WLR_REPO=https://github.com/ruby/ruby.git
export WLR_REPO_BRANCH=v3_2_2
export WLR_ENV_NAME=ruby/v3_2_2
export WLR_PACKAGE_VERSION=3.2.2
export WLR_PACKAGE_NAME=ruby
