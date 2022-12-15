#!/usr/bin/env bash

if [[ ! -v WASMLABS_ENV ]]
then
    echo "Wasmlabs environment is not set"
    exit 1
fi

if ! [ -x "$(command -v php)" ]
then
    echo "Native php is required in PATH on the host to act as orchestrator for php.wasm tests!"
    exit 1
fi

if [ -f "${WASMLABS_OUTPUT}/bin/php${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}" ]
then
    export WASMLABS_TESTED_MODULE="${WASMLABS_OUTPUT}/bin/php${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}"
else
    export WASMLABS_TESTED_MODULE="${WASMLABS_OUTPUT}/bin/php-cgi${WASMLABS_RUNTIME:+-$WASMLABS_RUNTIME}"
fi

if ! [ -x "${WASMLABS_TESTED_MODULE}" ]
then
    echo "WASM module not found at '${WASMLABS_TESTED_MODULE}'"
    exit 1
fi

cd "${WASMLABS_CHECKOUT_PATH}"
php -f run-tests.php -- -p ${WASMLABS_TEST_RUNTIME_WRAPPER} -j6 \
    tests/lang \
    tests/output \
    tests/strings

# tests/ \
# ext/standard/tests \
