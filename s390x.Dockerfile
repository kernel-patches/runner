# Self-Hosted IBM Z Github Actions Runner.

# Temporary image: amd64 dependencies.
FROM amd64/ubuntu:20.04 as ld-prefix
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install ca-certificates libicu66 libssl1.1

# Main image.
FROM s390x/ubuntu:20.04

# Packages for libbpf testing that are not installed by .github/actions/setup.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
        bc \
        bison \
        cmake \
        cpu-checker \
        curl \
        dumb-init \
        wget \
        flex \
        git \
        jq \
        linux-image-generic \
        qemu-system-s390x \
        rsync \
        software-properties-common \
        sudo \
        tree \
        zstd \
        iproute2 \
        iputils-ping

# amd64 Github Actions Runner.
ARG version=2.302.1
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
RUN curl -L https://github.com/actions/runner/releases/download/v${version}/actions-runner-linux-x64-${version}.tar.gz | tar -xz
USER root

# WARNING: This needs to be set at the end of the file or it will have side effects when building the container
# from within a foreign arch (like building on x86 host).
# amd64 dependencies.
# More specifically this is setting QEMU_LD_PREFIX that causes issue, but before touching system
# files, we may as well finish any prior installs.
COPY --from=ld-prefix / /usr/x86_64-linux-gnu/
RUN ln -fs ../lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /usr/x86_64-linux-gnu/lib64/
RUN ln -fs /etc/resolv.conf /usr/x86_64-linux-gnu/etc/
ENV QEMU_LD_PREFIX=/usr/x86_64-linux-gnu

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./bin/Runner.Listener", "run", "--startuptype", "service"]
