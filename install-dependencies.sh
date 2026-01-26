#!/bin/bash

set -xeuo pipefail

export DEPS=${1:-"all"} # "build", "run" or "all"

# Most of the BPF CI dependencies are set up by libbpf/ci/setup-build-env action
# This script runs a subset of that, in order to cache the packages at image build time
export LIBBPF_CI_TAG=${LIBBPF_CI_TAG:-"v4"}
export RUNNER_VERSION=${RUNNER_VERSION:-2.331.0}

# These should correspond to https://github.com/kernel-patches/vmtest/blob/master/.github/scripts/matrix.py#L20-L21
# Otherwise there is no point in caching the dependencies in the image
export GCC_VERSION=${GCC_VERSION:-15}
export LLVM_VERSION=${LLVM_VERSION:-21}

scratch=$(mktemp -d)
cd $scratch

# Install pre-requisites for GitHub Actions Runner client app
# https://github.com/actions/runner/blob/main/docs/start/envlinux.md
curl -Lf https://raw.githubusercontent.com/actions/runner/v${RUNNER_VERSION}/src/Misc/layoutbin/installdependencies.sh \
     -o install-gha-runner-deps.sh
bash install-gha-runner-deps.sh

# Use libbpf/ci/setup-build-env scripts
git clone --depth 1 --branch $LIBBPF_CI_TAG https://github.com/libbpf/ci.git actions

if [ "$DEPS" = "all" ] || [ "$DEPS" = "build" ]; then
        # do not install cross-compilation toolchain by default
        export TARGET_ARCH=$(uname -m)
        cd "${scratch}/actions/setup-build-env" && ./action.sh
fi

if [ "$DEPS" = "all" ] || [ "$DEPS" = "run" ]; then
        cd "${scratch}/actions/run-vmtest" && ./install-dependencies.sh
fi

cd / && rm -rf $scratch
sudo apt-get clean
