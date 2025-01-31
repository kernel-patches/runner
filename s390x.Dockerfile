# Self-Hosted IBM Z Github Actions Runner.
ARG UBUNTU_VERSION=noble
FROM ubuntu:${UBUNTU_VERSION}
ENV DEBIAN_FRONTEND=noninteractive

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

RUN apt-get update -y && apt-get install -y \
    aspnetcore-runtime-8.0

RUN apt-get clean

ARG version=2.321.0
ARG homedir=/actions-runner

# Copy scripts from  myoung34/docker-github-actions-runner
RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${version}/entrypoint.sh -o /entrypoint.sh && chmod 755 /entrypoint.sh
RUN curl -L https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${version}/token.sh -o /token.sh && chmod 755 /token.sh

RUN useradd -d ${homedir} -m runner
RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >>/etc/sudoers
# Make sure kvm group exists. This is a no-op when it does.
RUN addgroup --system kvm
RUN usermod -a -G kvm runner
USER runner
ENV USER=runner
WORKDIR ${homedir}

RUN curl -L https://github.com/theihor/s390x-actions-runner/releases/download/v${version}/actions-runner-linux-s390x-${version}.tar.gz | tar -xz
USER root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
