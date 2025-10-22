#!/bin/bash

set -euo pipefail

if [ "$(uname -m)" != "x86_64" ]; then
        echo "Skip setting up mirror repos in non-x86_64 image"
        exit 0
fi

mkdir -p /libbpfci/mirrors
git clone https://github.com/kernel-patches/bpf.git /libbpfci/mirrors/linux
chmod -R a+rX /libbpfci/mirrors
