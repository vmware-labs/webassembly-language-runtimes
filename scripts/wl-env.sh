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

    if [[ -f ${_PATH_TO_ENV}/wl-env-repo.sh ]]
    then
        source ${WASMLABS_ENV}/../wl-env-repo.sh --unset
    elif [[ -f ${_PATH_TO_ENV}/wl-env-local.sh ]]
    then
        source ${WASMLABS_ENV}/../wl-env-local.sh --unset
    fi

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

function _check_vars {
    for _VARNAME in $@
    do
        if [[ ! -v $_VARNAME ]]
        then
            echo "Variable ${_VARNAME} should be defined but is missing"
            exit 1
        fi
    done
}

function _load_env_file {
    local _PATH_TO_ENV=$1
    if [[ -f ${_PATH_TO_ENV}/wl-env-repo.sh ]]
    then
        if [[ -f ${_PATH_TO_ENV}/wl-env-local.sh ]]
        then
            echo "Both wl-env-repo and wl-env-local defined for ${_PATH_TO_ENV}"
            exit 1
        fi

        export WLR_ENV_SOURCE_TYPE=repo
        source ${_PATH_TO_ENV}/wl-env-repo.sh
        _check_vars WASMLABS_REPO WASMLABS_REPO_BRANCH

    elif [[ -f ${_PATH_TO_ENV}/wl-env-local.sh ]]
    then
        export WLR_ENV_SOURCE_TYPE=local
        source ${_PATH_TO_ENV}/wl-env-local.sh
    else
        echo "No wl-env-repo or wl-env-local defined for ${_PATH_TO_ENV}"
        exit 1
    fi
    _check_vars WASMLABS_ENV_NAME WASMLABS_PACKAGE_VERSION WASMLABS_PACKAGE_NAME
}

function _determine_wlr_output {
    local _BUILD_TYPE=$1
    if [ "${_BUILD_TYPE}" = "dependency" ]
    then
        export WASMLABS_OUTPUT_BASE=${WASMLABS_DEPS_ROOT}/build-output
        export WASMLABS_OUTPUT=${WASMLABS_DEPS_ROOT}/build-output
    else
        export WASMLABS_OUTPUT_BASE=${WASMLABS_REPO_ROOT}/build-output
        export WASMLABS_OUTPUT=${WASMLABS_OUTPUT_BASE}/${WASMLABS_ENV_NAME}${WASMLABS_BUILD_FLAVOR:+-$WASMLABS_BUILD_FLAVOR}
    fi
    _check_vars WASMLABS_OUTPUT_BASE WASMLABS_OUTPUT
}

function _determine_wlr_staging {
    local _BUILD_TYPE=$1
    if [ "${_BUILD_TYPE}" = "dependency" ]
    then
        local _WASMLABS_STAGING_ROOT=${WASMLABS_DEPS_ROOT}/build-staging
    else
        local _WASMLABS_STAGING_ROOT=${WASMLABS_REPO_ROOT}/build-staging
    fi
    export WASMLABS_STAGING=${_WASMLABS_STAGING_ROOT}/${WASMLABS_ENV_NAME}${WASMLABS_BUILD_FLAVOR:+-$WASMLABS_BUILD_FLAVOR}
    _check_vars WASMLABS_STAGING
}

function _determine_wlr_source_path {
    local _STAGING=$1
    local _SOURCE_TYPE=$2
    if [ "${_SOURCE_TYPE}" = "repo" ]
    then
        export WASMLABS_SOURCE_PATH=${_STAGING}/checkout
    elif [ "${_SOURCE_TYPE}" = "local" ]
    then
        export WASMLABS_SOURCE_PATH=${WASMLABS_ENV_NAME}
    else
        echo "Bad source type - '${_SOURCE_TYPE}'"
        exit 1
    fi
    _check_vars WASMLABS_SOURCE_PATH
}

function _determine_wlr_deps_root {
    local _STAGING=$1
    local _BUILD_TYPE=$2

    if [ "${_BUILD_TYPE}" != "dependency" ]
    then
        if [[ -v WASMLABS_DEPS_ROOT ]]
        then
            echo "Error in wl-env.sh. WASMLABS_DEPS_ROOT is already set to ${WASMLABS_DEPS_ROOT} when building a main target at ${PATH_TO_ENV}."
            exit 1
        fi
        # This is the main target, so set the env variable to use for its dependencies
        export WASMLABS_DEPS_ROOT=${_STAGING}/deps
    fi
}

function _load_local_conf {
    if [[ -f ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh && ! -v WASI_SDK_PATH && ! -v WASI_SDK_ASSET_NAME && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
    then
        echo "!! Using build tools as configured in '${WASMLABS_REPO_ROOT}/.wl-local-conf.sh'"
        source ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh

    elif [[ -f ${HOME}/.wl-local-conf.sh && ! -v WASI_SDK_PATH && ! -v WASI_SDK_ASSET_NAME && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
    then
        echo "!! Using build tools as configured in '${HOME}/.wl-local-conf.sh'"
        source ${HOME}/.wl-local-conf.sh
    fi
}

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

_load_env_file ${PATH_TO_ENV}

_determine_wlr_output ${WASMLABS_BUILD_TYPE}
mkdir -p ${WASMLABS_OUTPUT}

_determine_wlr_staging ${WASMLABS_BUILD_TYPE}
mkdir -p ${WASMLABS_STAGING}

_determine_wlr_source_path ${WASMLABS_STAGING} ${WLR_ENV_SOURCE_TYPE}

_determine_wlr_deps_root ${WASMLABS_STAGING} ${WASMLABS_BUILD_TYPE}
mkdir -p ${WASMLABS_DEPS_ROOT}

export WASMLABS_OLD_PS1="${PS1-}"
export PS1="(${WASMLABS_ENV_NAME}) ${PS1-}"

export WASMLABS_ENV=${PATH_TO_ENV}

_load_local_conf
