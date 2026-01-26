# hadolint ignore=DL3007
ARG UBUNTU_VERSION=noble
FROM myoung34/github-runner:ubuntu-${UBUNTU_VERSION}
# Redefining UBUNTU_VERSION without a value inherits the global default
ARG UBUNTU_VERSION

COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN bash /tmp/install-dependencies.sh run

COPY token.sh /token.sh
