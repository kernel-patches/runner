# hadolint ignore=DL3007
FROM myoung34/github-runner:latest
LABEL maintainer="sunyucong@gmail.com"

RUN apt-get update \
  && apt-get install -y cmake flex bison build-essential libssl-dev ncurses-dev xz-utils bc rsync libguestfs-tools qemu-kvm qemu-utils linux-image-generic zstd binutils-dev elfutils libcap-dev libelf-dev libdw-dev python3-docutils \
  && apt-get install -y g++ libelf-dev \
  && apt-get install -y iproute2 iputils-ping \
  && echo "deb https://apt.llvm.org/focal/ llvm-toolchain-focal main" > /etc/apt/sources.list.d/llvm.list \
  && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
  && apt-get update \
  && apt-get install -y clang lld llvm
