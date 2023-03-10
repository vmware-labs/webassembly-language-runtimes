#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

function wlr-env-unset() {
    if [[ ! -v WLR_ENV ]]
    then
        echo "Nothing to unset"
        return
    fi

    if [[ -f ${_PATH_TO_ENV}/wlr-env-repo.sh ]]
    then
        source ${WLR_ENV}/../wlr-env-repo.sh --unset
    elif [[ -f ${_PATH_TO_ENV}/wlr-env-local.sh ]]
    then
        source ${WLR_ENV}/../wlr-env-local.sh --unset
    fi

    unset WLR_SOURCE_PATH

    unset WLR_MAKE
    unset WLR_ENV_NAME
    unset WLR_STAGING
    unset WLR_OUTPUT_BASE
    unset WLR_OUTPUT
    unset WLR_REPO_ROOT

    if [[ -v WLR_OLD_PS1 ]]
    then
        export PS1="${WLR_OLD_PS1}"
        unset WLR_OLD_PS1
    fi

    unset -f wlr-env-unset
    unset WLR_ENV

    if (env | grep WLR_ -q)
    then
        echo "Leaked env variables were not cleared:"
        env | grep WLR_
    fi

    return
}
export -f wlr-env-unset

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
    if [[ -f ${_PATH_TO_ENV}/wlr-env-repo.sh ]]
    then
        if [[ -f ${_PATH_TO_ENV}/wlr-env-local.sh ]]
        then
            echo "Both wlr-env-repo and wlr-env-local defined for ${_PATH_TO_ENV}"
            exit 1
        fi

        export WLR_ENV_SOURCE_TYPE=repo
        source ${_PATH_TO_ENV}/wlr-env-repo.sh
        _check_vars WLR_REPO WLR_REPO_BRANCH

    elif [[ -f ${_PATH_TO_ENV}/wlr-env-local.sh ]]
    then
        export WLR_ENV_SOURCE_TYPE=local
        source ${_PATH_TO_ENV}/wlr-env-local.sh
    else
        echo "No wlr-env-repo or wlr-env-local defined for ${_PATH_TO_ENV}"
        exit 1
    fi
    _check_vars WLR_ENV_NAME WLR_PACKAGE_VERSION WLR_PACKAGE_NAME
}

function _determine_wlr_output {
    local _BUILD_TYPE=$1
    if [ "${_BUILD_TYPE}" = "dependency" ]
    then
        export WLR_OUTPUT_BASE=${WLR_DEPS_ROOT}/build-output
        export WLR_OUTPUT=${WLR_DEPS_ROOT}/build-output
    else
        export WLR_OUTPUT_BASE=${WLR_REPO_ROOT}/build-output
        export WLR_OUTPUT=${WLR_OUTPUT_BASE}/${WLR_ENV_NAME}${WLR_BUILD_FLAVOR:+-$WLR_BUILD_FLAVOR}
    fi
    _check_vars WLR_OUTPUT_BASE WLR_OUTPUT
}

function _determine_wlr_staging {
    local _BUILD_TYPE=$1
    if [ "${_BUILD_TYPE}" = "dependency" ]
    then
        local _WLR_STAGING_ROOT=${WLR_DEPS_ROOT}/build-staging
    else
        local _WLR_STAGING_ROOT=${WLR_REPO_ROOT}/build-staging
    fi
    export WLR_STAGING=${_WLR_STAGING_ROOT}/${WLR_ENV_NAME}${WLR_BUILD_FLAVOR:+-$WLR_BUILD_FLAVOR}
    _check_vars WLR_STAGING
}

function _determine_wlr_source_path {
    local _STAGING=$1
    local _SOURCE_TYPE=$2
    if [ "${_SOURCE_TYPE}" = "repo" ]
    then
        export WLR_SOURCE_PATH=${_STAGING}/checkout
    elif [ "${_SOURCE_TYPE}" = "local" ]
    then
        export WLR_SOURCE_PATH=${PATH_TO_ENV}
    else
        echo "Bad source type - '${_SOURCE_TYPE}'"
        exit 1
    fi
    _check_vars WLR_SOURCE_PATH
}

function _determine_wlr_deps_root {
    local _STAGING=$1
    local _BUILD_TYPE=$2

    if [ "${_BUILD_TYPE}" != "dependency" ]
    then
        if [[ -v WLR_DEPS_ROOT ]]
        then
            echo "Error in wlr-env.sh. WLR_DEPS_ROOT is already set to ${WLR_DEPS_ROOT} when building a main target at ${PATH_TO_ENV}."
            exit 1
        fi
        # This is the main target, so set the env variable to use for its dependencies
        export WLR_DEPS_ROOT=${_STAGING}/deps
    fi
}

function _load_local_conf {
    if [[ -f ${WLR_REPO_ROOT}/.wlr-local-conf.sh && ! -v WASI_SDK_PATH && ! -v WASI_SDK_ASSET_NAME && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
    then
        echo "!! Using build tools as configured in '${WLR_REPO_ROOT}/.wlr-local-conf.sh'"
        source ${WLR_REPO_ROOT}/.wlr-local-conf.sh

    elif [[ -f ${HOME}/.wlr-local-conf.sh && ! -v WASI_SDK_PATH && ! -v WASI_SDK_ASSET_NAME && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
    then
        echo "!! Using build tools as configured in '${HOME}/.wlr-local-conf.sh'"
        source ${HOME}/.wlr-local-conf.sh
    fi
}

# Expect path to root folder for build environment
PATH_TO_ENV="$( cd "$1" && pwd )"

if [[ ! -d ${PATH_TO_ENV} || ! -f ${PATH_TO_ENV}/wlr-build.sh ]]
then
    echo "Bad environment location: '${PATH_TO_ENV}'"
    return
fi

# Noop if environment is already set
if [[ -v WLR_ENV ]]
then
    echo "Environment is already set"
    return
fi

export WLR_REPO_ROOT="$(git rev-parse --show-toplevel)"
export WLR_MAKE=${WLR_REPO_ROOT}/wlr-make.sh

_load_env_file ${PATH_TO_ENV}

_determine_wlr_output ${WLR_BUILD_TYPE}
mkdir -p ${WLR_OUTPUT}

_determine_wlr_staging ${WLR_BUILD_TYPE}
mkdir -p ${WLR_STAGING}

_determine_wlr_source_path ${WLR_STAGING} ${WLR_ENV_SOURCE_TYPE}

_determine_wlr_deps_root ${WLR_STAGING} ${WLR_BUILD_TYPE}
mkdir -p ${WLR_DEPS_ROOT}

export WLR_OLD_PS1="${PS1-}"
export PS1="(${WLR_ENV_NAME}) ${PS1-}"

export WLR_ENV=${PATH_TO_ENV}

_load_local_conf
