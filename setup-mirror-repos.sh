#!/bin/bash

set -euo pipefail

MIRRORS_PATH=${MIRRORS_PATH:-/libbpfci/mirrors}

mkdir -p "$MIRRORS_PATH"
git clone https://github.com/kernel-patches/bpf.git "$MIRRORS_PATH/linux"
chmod -R a+rX "$MIRRORS_PATH"
