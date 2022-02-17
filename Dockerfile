# hadolint ignore=DL3007
FROM myoung34/github-runner:latest
LABEL maintainer="sunyucong@gmail.com"

RUN apt-get update && apt-get install -y cmake flex bison build-essential libssl-dev ncurses-dev xz-utils bc rsync libguestfs-tools qemu-kvm qemu-utils linux-image-generic zstd binutils-dev elfutils libcap-dev libelf-dev libdw-dev python3-docutils
