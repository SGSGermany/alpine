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
source "$CI_TOOLS_PATH/helper/container.sh.inc"
source "$CI_TOOLS_PATH/helper/container-alpine.sh.inc"

BUILD_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$BUILD_DIR/container.env"

readarray -t -d' ' TAGS < <(printf '%s' "$TAGS")

echo + "CONTAINER=\"\$(buildah from $(quote "$BASE_IMAGE"))\"" >&2
CONTAINER="$(buildah from "$BASE_IMAGE")"

echo + "MOUNT=\"\$(buildah mount $(quote "$CONTAINER"))\"" >&2
MOUNT="$(buildah mount "$CONTAINER")"

echo + "sed -i -E -e 's#^(https?://[^/]*alpinelinux.org/.*/community)$#@community \1#' …/etc/apk/repositories" >&2
sed -i -E -e 's#^(https?://[^/]*alpinelinux.org/.*/community)$#@community \1#' "$MOUNT/etc/apk/repositories"

cmd buildah run "$CONTAINER" -- \
    apk update

cmd buildah run "$CONTAINER" -- \
    apk upgrade

cleanup "$CONTAINER"

cmd buildah config \
    --annotation org.opencontainers.image.title="Alpine Linux" \
    --annotation org.opencontainers.image.description="@SGSGermany's base image for containers based on Alpine Linux." \
    --annotation org.opencontainers.image.url="https://github.com/SGSGermany/alpine" \
    --annotation org.opencontainers.image.authors="SGS Serious Gaming & Simulations GmbH" \
    --annotation org.opencontainers.image.vendor="SGS Serious Gaming & Simulations GmbH" \
    --annotation org.opencontainers.image.licenses="MIT" \
    --annotation org.opencontainers.image.base.name="$BASE_IMAGE" \
    --annotation org.opencontainers.image.base.digest="$(podman image inspect --format '{{.Digest}}' "$BASE_IMAGE")" \
    "$CONTAINER"

con_commit "$CONTAINER" "$IMAGE" "${TAGS[@]}"
