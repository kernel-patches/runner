#!/bin/bash

set -euo pipefail

# Most of the BPF CI dependencies are set up by libbpf/ci/setup-build-env action
# This script runs a subset of it, in order to cache the packages at image build time
export LIBBPF_CI_TAG=v3

# These should correspond to https://github.com/kernel-patches/vmtest/blob/master/.github/scripts/matrix.py#L20-L21
# Otherwise there is no point in caching dependencies in the image
export GCC_VERSION=14
export LLVM_VERSION=20

scratch=$(mktemp -d)
cd $scratch

git clone --depth 1 --branch $LIBBPF_CI_TAG https://github.com/libbpf/ci.git actions
cd actions
./setup-build-env/install_packages.sh
./setup-build-env/install_clang.sh
./run-vmtest/install-dependencies.sh

# do not install pahole and cross-compilation toolchain in the docker image
