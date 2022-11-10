#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" != "$0" ]; then
    echo "You must not source this script! Only call it in a new bash shell" >&2
    return
fi

wl-env-unset 2>/dev/null

THIS_REPO_ROOT="$(git rev-parse --show-toplevel)"

source ${THIS_REPO_ROOT}/scripts/wl-env.sh $1
${THIS_REPO_ROOT}/scripts/wl-setup-repo.sh || exit 1
${THIS_REPO_ROOT}/scripts/wl-build.sh
