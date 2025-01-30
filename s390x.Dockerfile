# Self-Hosted IBM Z Github Actions Runner.
ARG UBUNTU_VERSION=noble
FROM --platform=linux/s390x ubuntu:${UBUNTU_VERSION}
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install \
    bc bison cmake cpu-checker curl dumb-init ethtool flex gawk git \
    iproute2 iptables iputils-ping jq keyutils linux-image-generic \
    python3 rsync software-properties-common sudo tree wget zstd
RUN apt-get -y install \
    qemu-guest-agent qemu-kvm qemu-utils \
    qemu-system-arm qemu-system-s390x qemu-system-x86
RUN apt-get install -y \
    aspnetcore-runtime-8.0
RUN apt-get clean

ARG version=2.322.0
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
