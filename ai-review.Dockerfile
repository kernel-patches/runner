ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION=2.331.0

### git builder
FROM debian:latest AS git-builder
ARG DEBIAN_FRONTEND RUNNER_VERSION
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl sudo
COPY build-git.sh /tmp/build-git.sh
RUN bash /tmp/build-git.sh


### semcode builder
FROM debian:latest AS semcode-builder
ARG DEBIAN_FRONTEND RUNNER_VERSION
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl git sudo wget
COPY build-semcode.sh /tmp/build-semcode.sh
RUN bash /tmp/build-semcode.sh


### AI runtime
FROM debian:latest as runtime
ARG DEBIAN_FRONTEND RUNNER_VERSION

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    ca-certificates curl libcurl3-gnutls sudo wget unzip

# Install pre-requisites for GitHub Actions Runner client app
# https://github.com/actions/runner/blob/main/docs/start/envlinux.md
RUN curl -Lf https://raw.githubusercontent.com/actions/runner/v${RUNNER_VERSION}/src/Misc/layoutbin/installdependencies.sh \
         -o /tmp/install-gha-runner-deps.sh
RUN bash /tmp/install-gha-runner-deps.sh

COPY --from=git-builder /opt/git-staging/usr/local /usr/local

ENV MIRRORS_PATH=/ci/mirrors
COPY setup-mirror-repos.sh /tmp/setup-mirror-repos.sh
RUN bash /tmp/setup-mirror-repos.sh
RUN mkdir -p /libbpfci/mirrors && ln -s ${MIRRORS_PATH}/linux /libbpfci/mirrors/linux

COPY --from=semcode-builder /opt/semcode /usr/local/bin/semcode
COPY --from=semcode-builder /opt/semcode-index /usr/local/bin/semcode-index
COPY --from=semcode-builder /opt/semcode-mcp /usr/local/bin/semcode-mcp
COPY --from=semcode-builder /opt/semcode-lsp /usr/local/bin/semcode-lsp

RUN cd ${MIRRORS_PATH}/linux && \
    git remote add torvalds https://github.com/torvalds/linux.git && \
    git fetch torvalds && \
    git checkout origin/bpf-next
RUN cd ${MIRRORS_PATH}/linux && \
    semcode-index -d /ci/.semcode.db --git $(git describe --tags --abbrev=0)..HEAD
RUN semcode-index -d /ci/.semcode.db --lore bpf
