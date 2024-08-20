# hadolint ignore=DL3007
ARG UBUNTU_VERSION=focal
FROM myoung34/github-runner:ubuntu-${UBUNTU_VERSION}
# Redefining UBUNTU_VERSION without a value inherits the global default
ARG UBUNTU_VERSION

LABEL maintainer="sunyucong@gmail.com"

RUN apt-get update \
  && apt-get install -y cmake flex bison build-essential libssl-dev ncurses-dev xz-utils bc rsync libguestfs-tools qemu-kvm qemu-utils linux-image-generic zstd binutils-dev elfutils libcap-dev libelf-dev libdw-dev python3-docutils \
  && apt-get install -y g++ libelf-dev \
  && apt-get install -y iproute2 iputils-ping \
  && apt-get install -y cpu-checker qemu-kvm qemu-utils qemu-system-x86 qemu-system-s390x qemu-system-arm qemu-guest-agent ethtool keyutils iptables gawk \
  && echo "deb https://apt.llvm.org/${UBUNTU_VERSION}/ llvm-toolchain-${UBUNTU_VERSION} main" > /etc/apt/sources.list.d/llvm.list \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
  && apt-get update \
  && apt-get install -y clang lld llvm
