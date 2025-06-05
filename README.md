# BPF CI self-hosted Github Actions runners

This repository contains code to build and push docker images for BPF
CI self-hosted action runners.

The main image is based on https://github.com/myoung34/docker-github-actions-runner

The s390x image is custom: it uses code from
https://github.com/ppc64le/gaplib to build s390x binary of the
https://github.com/actions/runner, because s390x is not a platform
officially supported by github actions.

---

Other BPF CI repositories:
* https://github.com/kernel-patches/bpf
* https://github.com/kernel-patches/vmtest
* https://github.com/kernel-patches/kernel-patches-daemon
* https://github.com/libbpf/ci
