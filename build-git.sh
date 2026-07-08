#!/bin/bash

set -xeuo pipefail

# Build git from source using official kernel.org tarballs
# Usage: ./build-git.sh [version]
# If version is not specified, fetches the latest release

GIT_VERSION=${1:-}
GIT_MIRROR=${GIT_MIRROR:-https://mirrors.edge.kernel.org/pub/software/scm/git}

# Install build dependencies
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gettext \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    libssl-dev \
    zlib1g-dev

# Install a Rust toolchain. Since Git 2.55 the default `make all` builds a Rust
# component (target/release/libgitcore.a) and links it into the binaries; from
# Git 3.0 Rust is mandatory. Building it requires Cargo. Use rustup for a
# current toolchain, independent of the distro's packaged rustc/cargo version.
if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
        | sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path
    . "${CARGO_HOME:-${HOME}/.cargo}/env"
fi

# Determine version to install
if [ -z "${GIT_VERSION}" ]; then
    echo "Fetching latest git version..."
    GIT_VERSION=$(curl -fsSL "${GIT_MIRROR}/" | \
        grep -oP 'git-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | \
        sort -V | tail -1)
fi

echo "Building git version: ${GIT_VERSION}"

WORKDIR=$(mktemp -d)
cd "${WORKDIR}"

curl -fsSL "${GIT_MIRROR}/git-${GIT_VERSION}.tar.gz" | tar xz
cd "git-${GIT_VERSION}"

make prefix=/usr/local -j$(nproc) all
sudo make prefix=/usr/local DESTDIR=/opt/git-staging install

cd /
rm -rf "${WORKDIR}"
