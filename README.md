Alpine Linux
============

[`alpine`](https://ghcr.io/sgsgermany/alpine) is [@SGSGermany](https://github.com/SGSGermany)'s base image for containers based on [Alpine Linux](https://alpinelinux.org/). This image is built *daily* at 21:20 UTC on top of the [official Docker image](https://hub.docker.com/_/alpine) using [GitHub Actions](https://github.com/SGSGermany/alpine/actions/workflows/container-publish.yml).

Rebuilds are triggered only if Alpine publishes a new patch release, or if one of Alpine's Mini Root Filesystem packages were updated. Currently we create images for **Alpine 3.17**, **Alpine 3.16** and **Alpine 3.15**. Please note that we might add or drop branches at any time.

All images are tagged with their full Alpine version string, build date and build job number (e.g. `v3.15.4-20190618.1658821493.1`). The latest build of an Alpine release is additionally tagged without the build information (e.g. `v3.15.4`). If an image represents the latest version of an Alpine release branch, it is additionally tagged without the patch version (e.g. `v3.15`), and without the minor version (e.g. `v3`); both without and with build information (e.g. `v3.15-20190618.1658821493.1` and `v3-20190618.1658821493.1`). The latest build of the latest Alpine version is furthermore tagged with `latest`.
