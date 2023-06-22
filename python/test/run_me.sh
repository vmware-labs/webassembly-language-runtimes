#!/usr/bin/env bash

if [[ "$(realpath $PWD)" != "$(realpath $(dirname $BASH_SOURCE))" ]]
then
  echo "This script works only if called from its location as PWD"
  exit 1
fi

TESTS=$(for t in */test.py; do echo $(dirname $t); done)

status=0

for test_dir in "$TESTS"; do
    echo "Running test in '${test_dir}'..."
    if diff ${test_dir}/test.stdout <($WLR_TEST_RUNTIME \
            --mapdir /usr::${WLR_OUTPUT}/usr \
            --mapdir /test::./${test_dir} \
            --mapdir .::./${test_dir} \
            ${WLR_TESTED_MODULE} \
            /test/test.py); then
        echo "${test_dir}/test.py passed!"
    else
        echo "${test_dir}/test.py failed!"
        status=$(expr ${status} + 1)
    fi
done

exit $status
