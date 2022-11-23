#!/usr/bin/env bash

# This script allows you to tag a runtime that lives inside of this
# project. It only accepts one parameter, that is the path to the
# project to be tagged. A tag will be created locally that contains
# the date and a the short SHA of HEAD.
#
# When the tag is pushed to the remote repository, automation will
# take care of running the tests and generating the public artifacts.

set -e

TAG_DATE=$(date -u '+%Y%m%d')
SHORT_SHA=$(git rev-parse --short HEAD)

if [ $# -ne 1 ]; then
    echo "$0 usage: $0 path/to/project"
    exit 1
fi

if [ ! -f $1/wl-tag.sh ]; then
    echo "cannot tag $1; missing $1/wl-tag.sh"
    exit 1
fi

source $1/wl-tag.sh
WLR_FINAL_TAG="${WLR_TAG}+${TAG_DATE}-${SHORT_SHA}"

git tag -s $WLR_FINAL_TAG -m "Release $WLR_TAG"

echo "tag created: $WLR_FINAL_TAG"
