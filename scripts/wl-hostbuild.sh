#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if [[ ! -v WASI_SDK_PATH ]]
then
    echo "Please set WASI_SDK_PATH and run again"
    exit 1
fi

env -u CC -u LD -u CXX -u NM -u AR -u RANLIB $@ || exit 1
