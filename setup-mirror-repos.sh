#!/bin/bash

set -euo pipefail

mkdir -p /libbpfci/mirrors
git clone https://github.com/kernel-patches/bpf.git /libbpfci/mirrors/linux
chmod -R a+rX /libbpfci/mirrors
