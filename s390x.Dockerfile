# Self-Hosted IBM Z Github Actions Runner

ARG RUNNER_VERSION=2.324.0

FROM ubuntu:noble AS build-s390x-runner-binaries
ENV DEBIAN_FRONTEND=noninteractive

ARG S390X_RUNNER_REPO="https://github.com/ppc64le/gaplib.git"
ARG S390X_RUNNER_REPO_REV=main
ARG S390X_PATCH=patches/runner-main-sdk8-s390x.patch

ARG RUNNER_REPO="https://github.com/actions/runner"
ARG RUNNER_VERSION

RUN apt-get update -y
RUN apt-get -y install curl git jq sudo wget
RUN apt-get -y install dotnet-sdk-8.0

RUN git clone ${S390X_RUNNER_REPO} /opt/s390x-runner
WORKDIR /opt/s390x-runner
RUN git checkout ${S390X_RUNNER_REPO_REV}
# RUN cp build-files/99synaptics /etc/apt/apt.conf.d/
# RUN cp build-files/01-nodoc /etc/dpkg/dpkg.cfg.d/
RUN cp ${S390X_PATCH} /opt/runner.patch
COPY 0001-Fix-TestRunnerJobRequestMessageFromRunService_AuthMi.patch /opt/test.patch

RUN git clone -b v${RUNNER_VERSION} ${RUNNER_REPO} /opt/runner
WORKDIR /opt/runner
RUN git apply /opt/runner.patch
RUN git apply /opt/test.patch

# dotnet refuses to build if global.json version and dotnet version don't match
# it's difficult to get the right version of dotnet on s390x (the best way is to build it)
# so replacing the version in global.json is an acceptable workaround
RUN jq --arg ver "$(dotnet --version)" '.sdk.version = $ver' src/global.json > tmp.json && \
    mv tmp.json src/global.json

WORKDIR /opt/runner/src
RUN ./dev.sh layout
RUN ./dev.sh package
RUN ./dev.sh test

RUN mv "/opt/runner/_package/actions-runner-linux-s390x-${RUNNER_VERSION#v}.tar.gz" /opt/runner.tar.gz

FROM ubuntu:noble AS prepare-runner-image
ENV DEBIAN_FRONTEND=noninteractive

ARG RUNNER_HOME=/actions-runner
ARG RUNNER_VERSION

RUN apt-get update -y
RUN apt-get install -y \
    bc bison build-essential cmake cpu-checker curl dumb-init elfutils ethtool flex g++ gawk git \
    iproute2 iptables iputils-ping jq keyutils libguestfs-tools python3-minimal python3-docutils \
    rsync software-properties-common sudo tree wget xz-utils zstd
RUN apt-get install -y \
    binutils-dev libcap-dev libdw-dev libelf-dev libssl-dev ncurses-dev
RUN apt-get install -y \
    qemu-guest-agent qemu-kvm qemu-system-arm qemu-system-s390x qemu-system-x86 qemu-utils
RUN apt-get install -y aspnetcore-runtime-8.0

# Install LLVM with automatic script (https://apt.llvm.org)
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

RUN apt-get clean

# Copy scripts from myoung34/docker-github-actions-runner
RUN curl -Lf https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${RUNNER_VERSION}/entrypoint.sh -o /entrypoint.sh && chmod 755 /entrypoint.sh

# RUN curl -Lf https://raw.githubusercontent.com/myoung34/docker-github-actions-runner/${RUNNER_VERSION}/token.sh -o /token.sh && chmod 755 /token.sh
COPY token.sh /token.sh

RUN useradd -d ${RUNNER_HOME} -m runner
RUN echo "runner ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >>/etc/sudoers
# Make sure kvm group exists. This is a no-op when it does.
RUN addgroup --system kvm
RUN usermod -a -G kvm runner
USER runner
ENV USER=runner
WORKDIR ${RUNNER_HOME}

COPY --from=build-s390x-runner-binaries /opt/runner.tar.gz /opt/runner.tar.gz
RUN tar -xzf /opt/runner.tar.gz -C ${RUNNER_HOME}
USER root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
