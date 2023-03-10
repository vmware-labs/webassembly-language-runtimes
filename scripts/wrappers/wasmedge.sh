#!/usr/bin/env bash

if [[ ! -v WLR_TESTED_MODULE ]]
then
    echo "WLR tested module is not set"
    exit 1
fi

wasmedge --dir /:/ ${WLR_TESTED_MODULE} $@
