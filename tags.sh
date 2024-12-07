#!/bin/bash
# Alpine Linux
# @SGSGermany's base image for containers based on Alpine Linux.
#
# Copyright (c) 2022  SGS Serious Gaming & Simulations GmbH
#
# This work is licensed under the terms of the MIT license.
# For a copy, see LICENSE file or <https://opensource.org/licenses/MIT>.
#
# SPDX-License-Identifier: MIT
# License-Filename: LICENSE

set -eu -o pipefail
export LC_ALL=C.UTF-8

[ -v CI_TOOLS ] && [ "$CI_TOOLS" == "SGSGermany" ] \
    || { echo "Invalid build environment: Environment variable 'CI_TOOLS' not set or invalid" >&2; exit 1; }

[ -v CI_TOOLS_PATH ] && [ -d "$CI_TOOLS_PATH" ] \
    || { echo "Invalid build environment: Environment variable 'CI_TOOLS_PATH' not set or invalid" >&2; exit 1; }

source "$CI_TOOLS_PATH/helper/common.sh.inc"

BUILD_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$BUILD_DIR/container.env"

BUILD_INFO=""
if [ $# -gt 0 ] && [[ "$1" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    BUILD_INFO=".${1,,}"
fi

# pull base image
echo + "IMAGE_ID=\"\$(podman pull $(quote "$BASE_IMAGE"))\"" >&2
IMAGE_ID="$(podman pull "$BASE_IMAGE" || true)"

if [ -z "$IMAGE_ID" ]; then
    echo "Failed to pull image '$BASE_IMAGE': No image with this tag found" >&2
    exit 1
fi

# read Alpine's release file
echo + "VERSION=\"\$(podman run -i --rm $IMAGE_ID cat /etc/alpine-release)\"" >&2
VERSION="$(podman run -i --rm "$IMAGE_ID" cat /etc/alpine-release)"

if [ -z "$VERSION" ]; then
    echo "Unable to read Alpine's release file '/etc/alpine-release': Unable to read from file" >&2
    exit 1
elif ! [[ "$VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)([+~-]|$) ]]; then
    echo "Unable to read Alpine's release file '/etc/alpine-release': '$VERSION' is no valid version" >&2
    exit 1
fi

VERSION_FULL="$VERSION"
VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
VERSION_MINOR="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
VERSION_MAJOR="${BASH_REMATCH[1]}"

# list all available tags of the base image do determine the respective latest version of a branch
ls_versions() {
    jq -re --arg "VERSION" "$1" \
        '.Tags[]|select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$") and startswith($VERSION + "."))' \
        <<<"$BASE_IMAGE_REPO_TAGS" | sort_semver
}

echo + "BASE_IMAGE_REPO_TAGS=\"\$(skopeo list-tags $(quote "docker://${BASE_IMAGE%:*}"))\"" >&2
BASE_IMAGE_REPO_TAGS="$(skopeo list-tags "docker://${BASE_IMAGE%:*}" || true)"

if [ -z "$BASE_IMAGE_REPO_TAGS" ]; then
    echo "Unable to read tags from container repository 'docker://${BASE_IMAGE%:*}'" >&2
    exit 1
fi

# build tags
BUILD_INFO="$(date --utc +'%Y%m%d')$BUILD_INFO"

TAGS=( "v$VERSION" "v$VERSION-$BUILD_INFO" )

if [ "$VERSION" == "$(ls_versions "$VERSION_MINOR" | head -n 1)" ]; then
    TAGS+=( "v$VERSION_MINOR" "v$VERSION_MINOR-$BUILD_INFO" )

    if [ "$VERSION" == "$(ls_versions "$VERSION_MAJOR" | head -n 1)" ]; then
        TAGS+=( "v$VERSION_MAJOR" "v$VERSION_MAJOR-$BUILD_INFO" )

        if ! ls_versions "$((VERSION_MAJOR + 1))" > /dev/null; then
            TAGS+=( "latest" )
        fi
    fi
fi

printf 'MILESTONE="%s"\n' "$VERSION_MINOR"
printf 'VERSION="%s"\n' "$VERSION_FULL"
printf 'TAGS="%s"\n' "${TAGS[*]}"
