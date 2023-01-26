#!/usr/bin/env bash

# This script patches a wasm binary passed as first argument.
# It changes the signature of the imported sock_accept method from WASI
# to the signature defined by WasmEdge
#
# Note: the script assumes that it is working on an optimized binary
# with stripped function names. The used regexes won't work otherwise.

if [[ ! -f "$1" ]]
then
    echo "Pass target file as argument. Could not find a file at '$1'"
    exit 1
fi

export TARGET_FILE=$1
export WAT_FILE=/tmp/python.wat


echo "Converting to wat at ${WAT_FILE}... "
${WABT_ROOT}/bin/wasm2wat ${TARGET_FILE} -o ${WAT_FILE} || exit 1
cp ${WAT_FILE} ${WAT_FILE}_original.txt

echo "Patching wat..."
export WASMEDGE_SOCK_ACCEPT_TYPE="(func (param i32 i32) (result i32))"

# Find a type that matches the sock_accept signature in wasmedge
export TARGET_TYPE=$(grep "(type (;.*;) ${WASMEDGE_SOCK_ACCEPT_TYPE})" ${WAT_FILE} | cut -f 2 -d \;)

# Find the index of the sock_accept imported function
export FUNC_IDX=$(grep '(import "wasi_snapshot_preview1" "sock_accept" (func (;.*;) (type .*)))' $WAT_FILE | cut -f 2 -d \;)

# Change the type based on the function index
sed -i -e "s/(func (;${FUNC_IDX};) (type .*)))/(func (;${FUNC_IDX};) (type ${TARGET_TYPE})))/g" ${WAT_FILE} || exit 1

# Delete the line before each call to the function index to ignore the passed parameter
# Obviously this way sock_accept will not work correctly, but will at least run
sed -ni "/call ${FUNC_IDX}\$/{x;d;};1h;1!{x;p;};\${x;p;}" ${WAT_FILE} || exit 1

echo "Converting to wasm..."
cp ${TARGET_FILE} ${TARGET_FILE}_original
${WABT_ROOT}/bin/wat2wasm ${WAT_FILE} -o ${TARGET_FILE} --debug-names || exit 1
