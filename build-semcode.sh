#!/bin/bash

set -xeuo pipefail

SEMCODE_ORIGIN=${SEMCODE_ORIGIN:-https://github.com/facebookexperimental/semcode.git}
SEMCODE_REVISION=${SEMCODE_REVISION:-main}
SEMCODE_SRC=${SEMCODE_SRC:-/tmp/semcode}

sudo apt-get install -y build-essential libclang-dev protobuf-compiler libprotobuf-dev libssl-dev pkg-config

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

if [[ ! -d $SEMCODE_SRC ]]; then
        cd /tmp
        git clone ${SEMCODE_ORIGIN} semcode
        cd semcode
        git checkout ${SEMCODE_REVISION} -b local
else
        cd $SEMCODE_SRC
fi

. $HOME/.cargo/env
cargo build --release

cd target/release
cp semcode /opt/semcode
cp semcode-index /opt/semcode-index
cp semcode-mcp /opt/semcode-mcp
cp semcode-lsp /opt/semcode-lsp
