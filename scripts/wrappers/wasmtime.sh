#!/usr/bin/env bash

if [[ ! -v WASMLABS_TESTED_MODULE ]]
then
    echo "Wasmlabs tested module is not set"
    exit 1
fi

wasmtime --mapdir /::/ ${WASMLABS_TESTED_MODULE} -- $@
