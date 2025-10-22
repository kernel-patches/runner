#!/bin/bash

set -euo pipefail

# Most of the BPF CI dependencies are set up by libbpf/ci/setup-build-env action
# This script runs a subset of that, in order to cache the packages at image build time
export LIBBPF_CI_TAG=v3

# These should correspond to https://github.com/kernel-patches/vmtest/blob/master/.github/scripts/matrix.py#L20-L21
# Otherwise there is no point in caching dependencies in the image
export GCC_VERSION=15
export LLVM_VERSION=21

# do not install pahole and cross-compilation toolchain in the docker image
export TARGET_ARCH=$(uname -m)
export PAHOLE_BRANCH=none

scratch=$(mktemp -d)
cd $scratch
git clone --depth 1 --branch $LIBBPF_CI_TAG https://github.com/libbpf/ci.git actions

# Install build dependencies only on x86_64, we cross-compile everything else
if [ "$(uname -m)" == "x86_64" ]; then
        cd "${scratch}/actions/setup-build-env" && ./action.sh
fi

cd "${scratch}/actions/run-vmtest" && ./install-dependencies.sh
