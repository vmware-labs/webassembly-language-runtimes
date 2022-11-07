if [[ ! -v WASI_SDK_ROOT ]]
then
    echo "Please set WASI_SDK_ROOT and run again"
    exit 1
fi
export WASI_SDK_ROOT=$(readlink -f $WASI_SDK_ROOT)

if [[ ! -v WASMLABS_BUILD_OUTPUT ]]
then
    echo "Please set WASMLABS_BUILD_OUTPUT and run again. Artifacts will go to \$WASMLABS_BUILD_OUTPUT/{bin/include/lib/share}"
    exit 1
fi
export WASMLABS_BUILD_OUTPUT=$(readlink -f $WASMLABS_BUILD_OUTPUT)

PATCH_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/patch.v1.diff
if [[ ! -f $PATCH_PATH ]]
then
    echo "Cannod find the patch file in $PATCH_PATH"
    exit 1
fi

pushd $WASMLABS_BUILD_OUTPUT
function onExit {
    popd
}
trap onExit EXIT

mkdir build 2>/dev/null
cd build

git clone --depth=1 -b version-3.39.2 https://github.com/sqlite/sqlite.git sqlite-build-version-3.39.2 && cd sqlite-build-version-3.39.2
git apply $PATCH_PATH
./wasmlabs-build.sh
