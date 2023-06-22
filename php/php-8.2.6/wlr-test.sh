#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

if ! [ -x "$(command -v php)" ]
then
    echo "Native php is required in PATH on the host to act as orchestrator for php.wasm tests!"
    exit 1
fi

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    WLR_BINARY_WUFFIX=-wasmedge
fi

if [ -f "${WLR_OUTPUT}/bin/php${WLR_BINARY_WUFFIX}" ]
then
    export WLR_TESTED_MODULE="${WLR_OUTPUT}/bin/php${WLR_BINARY_WUFFIX}.wasm"
else
    export WLR_TESTED_MODULE="${WLR_OUTPUT}/bin/php-cgi${WLR_BINARY_WUFFIX}.wasm"
fi

if ! [ -f "${WLR_TESTED_MODULE}" ]
then
    echo "WASM module not found at '${WLR_TESTED_MODULE}'"
    exit 1
fi

cd "${WLR_SOURCE_PATH}"
echo "Calling 'WLR_TESTED_MODULE=${WLR_TESTED_MODULE} php -f run-tests.php -- -p ${WLR_TEST_RUNTIME_WRAPPER} -j6' to run tests..."
php -f run-tests.php -- -p ${WLR_TEST_RUNTIME_WRAPPER} -j6 \
    tests/lang \
    tests/output \
    tests/strings \
    Zend/tests/fibers
