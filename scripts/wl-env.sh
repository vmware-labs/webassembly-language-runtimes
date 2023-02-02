#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

function wl-env-unset() {
    if [[ ! -v WASMLABS_ENV ]]
    then
        echo "Nothing to unset"
        return
    fi

    source ${WASMLABS_ENV}/../wl-env-repo.sh --unset
    unset WASMLABS_SOURCE_PATH
    unset WASMLABS_TAG

    unset WASMLABS_MAKE
    unset WASMLABS_ENV_NAME
    unset WASMLABS_STAGING
    unset WASMLABS_OUTPUT_BASE
    unset WASMLABS_OUTPUT
    unset WASMLABS_REPO_ROOT

    if [[ -v WASMLABS_OLD_PS1 ]]
    then
        export PS1="${WASMLABS_OLD_PS1}"
        unset WASMLABS_OLD_PS1
    fi

    unset -f wl-env-unset
    unset WASMLABS_ENV

    if (env | grep WASMLABS_ -q)
    then
        echo "Leaked env variables were not cleared:"
        env | grep WASMLABS_
    fi

    return
}
export -f wl-env-unset


# Expect path to root folder for build environment
PATH_TO_ENV="$( cd "$1" && pwd )"

if [[ ! -d ${PATH_TO_ENV} || ! -f ${PATH_TO_ENV}/wl-build.sh ]]
then
    echo "Bad environment location: '${PATH_TO_ENV}'"
    return
fi

# Noop if environment is already set
if [[ -v WASMLABS_ENV ]]
then
    echo "Environment is already set"
    return
fi

export WASMLABS_REPO_ROOT="$(git rev-parse --show-toplevel)"
export WASMLABS_MAKE=${WASMLABS_REPO_ROOT}/wl-make.sh

if [[ -f ${PATH_TO_ENV}/../wl-env-repo.sh ]]
then
    # Setup source and staging for targets from another repository
    source ${PATH_TO_ENV}/../wl-env-repo.sh

    export WASMLABS_TAG=$(basename ${PATH_TO_ENV})

    export WASMLABS_ENV_NAME="${WASMLABS_REPO_NAME}/${WASMLABS_TAG}"
    export WASMLABS_STAGING=${WASMLABS_REPO_ROOT}/build-staging/${WASMLABS_ENV_NAME}
    export WASMLABS_SOURCE_PATH=${WASMLABS_STAGING}/checkout

else
    # Setup source and stating for targets in this repository
    RELATIVE_PATH_TO_ENV=$(realpath --relative-to ${WASMLABS_REPO_ROOT} ${PATH_TO_ENV})
    export WASMLABS_ENV_NAME=${RELATIVE_PATH_TO_ENV}
    export WASMLABS_STAGING=${WASMLABS_REPO_ROOT}/build-staging/${WASMLABS_ENV_NAME}
    export WASMLABS_SOURCE_PATH=${WASMLABS_ENV_NAME}
fi

export WASMLABS_OUTPUT_BASE=${WASMLABS_REPO_ROOT}/build-output
export WASMLABS_OUTPUT=${WASMLABS_OUTPUT_BASE}/${WASMLABS_ENV_NAME}

export WASMLABS_OLD_PS1="${PS1-}"
export PS1="(${WASMLABS_ENV_NAME}) ${PS1-}"

mkdir -p ${WASMLABS_STAGING}
mkdir -p ${WASMLABS_OUTPUT}/bin
mkdir -p ${WASMLABS_OUTPUT}/include
mkdir -p ${WASMLABS_OUTPUT}/lib

export WASMLABS_ENV=${PATH_TO_ENV}

if [[ -f ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh && ! -v WASI_SDK_ROOT && ! -v BINARYEN_PATH && ! -v WABT_ROOT ]]
then
    echo "!! Using build tools as configured in '${WASMLABS_REPO_ROOT}/.wl-local-conf.sh'"
    source ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh

elif [[ -f ${HOME}/.wl-local-conf.sh && ! -v WASI_SDK_ROOT && ! -v BINARYEN_PATH && ! -v WABT_ROOT ]]
then
    echo "!! Using build tools as configured in '${HOME}/.wl-local-conf.sh'"
    source ${HOME}/.wl-local-conf.sh
fi
