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
export LC_ALL=C

ls_versions() {
    jq -re --arg "VERSION" "$1" \
        '.Tags[]|select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$") and startswith($VERSION + "."))' \
        <<<"$BASE_IMAGE_REPO_TAGS" | sort_semver
}

sort_semver() {
    sed '/-/!{s/$/_/}' | sort -V -r | sed 's/_$//'
}

BUILD_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[ -f "$BUILD_DIR/container.env" ] && source "$BUILD_DIR/container.env" \
    || { echo "Container environment file 'container.env' not found" >&2; exit 1; }

BUILD_INFO=""
if [ $# -gt 0 ] && [[ "${1,,}" =~ ^[a-z0-9_.-]+$ ]]; then
    BUILD_INFO=".${1,,}"
fi

echo + "CONTAINER=\"\$(buildah from $BASE_IMAGE)\"" >&2
CONTAINER="$(buildah from "$BASE_IMAGE" || true)"

if [ -z "$CONTAINER" ]; then
    echo "Failed to pull image '$BASE_IMAGE': No image with this tag found" >&2
    exit 1
fi

VERSION="$(buildah run "$CONTAINER" -- cat /etc/alpine-release)"
if [ -z "$VERSION" ]; then
    echo "Unable to read Alpine's release file '/etc/alpine-release': Unable to read from file" >&2
    exit 1
elif ! [[ "$VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)([+~-]|$) ]]; then
    echo "Unable to read Alpine's release file '/etc/alpine-release': '$VERSION' is no valid version" >&2
    exit 1
fi

VERSION="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
VERSION_MINOR="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}"
VERSION_MAJOR="${BASH_REMATCH[1]}"

BASE_IMAGE_REPO_TAGS="$(skopeo list-tags "docker://${BASE_IMAGE%:*}" || true)"
if [ -z "$BASE_IMAGE_REPO_TAGS" ]; then
    echo "Unable to read tags from container repository 'docker://${BASE_IMAGE%:*}'" >&2
    exit 1
fi

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

printf 'VERSION="%s"\n' "$VERSION"
printf 'TAGS="%s"\n' "${TAGS[*]}"
