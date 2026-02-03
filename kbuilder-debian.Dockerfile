FROM debian:testing

ARG RUNNER_VERSION=2.331.0
ARG LIBBPF_CI_TAG=v4

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl git sudo wget

COPY setup-mirror-repos.sh /tmp/setup-mirror-repos.sh
RUN bash /tmp/setup-mirror-repos.sh

COPY install-dependencies.sh /tmp/install-dependencies.sh
RUN bash /tmp/install-dependencies.sh build

RUN apt-get clean
