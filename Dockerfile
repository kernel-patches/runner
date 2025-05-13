# hadolint ignore=DL3007
ARG UBUNTU_VERSION=noble
FROM myoung34/github-runner:ubuntu-${UBUNTU_VERSION}
# Redefining UBUNTU_VERSION without a value inherits the global default
ARG UBUNTU_VERSION

LABEL maintainer="sunyucong@gmail.com"

RUN apt-get update -y && apt-get install -y \
    bc bison build-essential cmake cpu-checker curl dumb-init elfutils ethtool flex g++ gawk git \
    iproute2 iptables iputils-ping jq keyutils libguestfs-tools python3-minimal python3-docutils \
    rsync software-properties-common sudo tree wget xz-utils zstd

RUN apt-get update -y && apt-get install -y \
    binutils-dev libcap-dev libdw-dev libelf-dev libssl-dev ncurses-dev

RUN apt-get update -y && apt-get install -y \
    qemu-guest-agent qemu-kvm qemu-system-arm qemu-system-s390x qemu-system-x86 qemu-utils

# Install LLVM with automatic script (https://apt.llvm.org)
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

COPY token.sh /token.sh

RUN apt-get clean
