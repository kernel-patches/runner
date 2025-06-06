# hadolint ignore=DL3007
ARG UBUNTU_VERSION=noble
FROM myoung34/github-runner:ubuntu-${UBUNTU_VERSION}
# Redefining UBUNTU_VERSION without a value inherits the global default
ARG UBUNTU_VERSION

COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN /tmp/install-dependencies.sh

RUN apt-get clean

COPY token.sh /token.sh

