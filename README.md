Alpine Linux
============

[`alpine`](https://ghcr.io/sgsgermany/alpine) is [@SGSGermany](https://github.com/SGSGermany)'s base image for containers based on [Alpine Linux](https://alpinelinux.org/). This image is built *daily* at 21:20 UTC on top of the [official Docker image](https://hub.docker.com/_/alpine) using [GitHub Actions](https://github.com/SGSGermany/alpine/actions/workflows/container-publish.yml).

Rebuilds are triggered only if Alpine publishes a new patch release, or if one of Alpine's Mini Root Filesystem packages were updated. Currently we create images for **Alpine 3.23**, **Alpine 3.22**, **Alpine 3.21**, and **Alpine 3.20**. Please note that we might add or drop branches at any time, but usually around upstream's actual release resp. end-of-life dates.

All images are tagged with their full Alpine version string, build date and build job number (e.g. `v3.15.4-20190618.1658821493.1`). The latest build of an Alpine release is additionally tagged without the build information (e.g. `v3.15.4`). If an image represents the latest version of an Alpine release branch, it is additionally tagged without the patch version (e.g. `v3.15`), and without the minor version (e.g. `v3`); both without and with build information (e.g. `v3.15-20190618.1658821493.1` and `v3-20190618.1658821493.1`). The latest build of the latest Alpine version is furthermore tagged with `latest`.

Please note that we disable [Alpine's `community` repository](https://pkgs.alpinelinux.org/packages?name=&branch=edge&repo=community&arch=x86_64&maintainer=) by default. The reason is its limited support: In the [`main` repository](https://pkgs.alpinelinux.org/packages?name=&branch=edge&repo=main&arch=x86_64&maintainer=) we can expect the full support cycle of 2 years, but `community` is only supported for about 6 months, i.e. until the next stable release (see [Alpine wiki](https://wiki.alpinelinux.org/wiki/Repositories) for more information). If you want to install packages from the `community` repository, make sure to always use Alpine's latest stable branch. You can then either re-enable the repository as a whole (run `sed -i -E 's/^@community (.+)$/\1/' /etc/apk/repositories`), or install single packages by tagging them with `@community` (e.g. `apk add --no-cache package-name@community`).

Licensing
---------

Made with ♥ by [SGS Serious Gaming & Simulations](https://www.sgs-online.info).

This repository contains scripts and resources for building and continuously integrating an OCI container image, as well as components used to run it (e.g., setup scripts, runtime configuration, modified config files).

All contents of this repository are free and open-source software, licensed under the terms of the [MIT License](./LICENSE).

Please note that the resulting OCI container image includes not only the components provided in this repository, but also the third-party components constituting the operating system included in the image. These are licensed under their respective licenses and are not covered by the MIT License of this repository. Please refer to the respective component licenses for details.
