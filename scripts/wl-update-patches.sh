#!/bin/bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

cd ${WASMLABS_CHECKOUT_PATH} || exit 1
mv -f ${WASMLABS_ENV}/patches/* /tmp/
git format-patch -X ${WASMLABS_TAG} -o ${WASMLABS_ENV}/patches || exit 1
