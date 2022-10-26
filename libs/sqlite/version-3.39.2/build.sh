if [[ ! -v WASI_SDK_ROOT ]]
then
    echo "Please set WASI_SDK_ROOT and run again"
    exit 1
fi
export WASI_SDK_ROOT=$(readlink -f $WASI_SDK_ROOT)

if [[ ! -v WASMLABS_BUILD_ROOT ]]
then
    echo "Please set WASMLABS_BUILD_ROOT and run again. Artifacts will go to \$WASMLABS_BUILD_ROOT/{include/lib/share}"
    exit 1
fi
export WASMLABS_BUILD_ROOT=$(readlink -f $WASMLABS_BUILD_ROOT)

PATCH_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/patch.v1.diff
if [[ ! -f $PATCH_PATH ]]
then
    echo "Cannod find the patch file in $PATCH_PATH"
    exit 1
fi

pushd $WASMLABS_BUILD_ROOT
function onExit {
    popd
}
trap onExit EXIT

git clone --depth=1 -b version-3.39.2 https://github.com/sqlite/sqlite.git sqlite-3.39.2-build && cd sqlite-3.39.2-build
git apply $PATCH_PATH
./wasmlabs-build.sh
