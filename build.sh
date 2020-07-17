#!/bin/bash

docker build --build-arg LLVM_VERSION=8 \
  -t bpftrace-builder-ubuntu-glibc \
  -f docker/Dockerfile.ubuntu-glibc \
  docker/ && \
docker run --privileged \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  -v /sys/kernel/debug:/sys/kernel/debug:rw \
  -v /lib/modules:/lib/modules:ro \
  -v /usr/src:/usr/src:ro \
  -e RUN_ALL_TESTS=1 \
  -e STATIC_LINKING=ON \
  -e EMBED_CLANG=ON \
  -e CMAKE_EXTRA_FLAGS="${CMAKE_EXTRA_FLAGS}" \
  -e RUNTIME_TEST_DISABLE="builtin.cgroup,probe.kprobe_offset_fail_size" \
  -e CC="${CC}" \
  -e CXX="${CXX}" \
  bpftrace-builder-ubuntu-glibc \
  ${PWD}/build-release-ubuntu \
  release \
  -j$(nproc)
