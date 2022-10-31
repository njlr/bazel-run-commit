#!/bin/bash

set -e
set -o pipefail

# 1
rm -rf ./bazel-*

bazel clean

RUN_ID=$(cat /proc/sys/kernel/random/uuid)

bazel build //:image_archive

sha256sum bazel-bin/image_archive.tar

cp bazel-bin/image_archive.tar ./image_archive_$RUN_ID.tar

# 2
rm -rf ./bazel-*

bazel clean

RUN_ID=$(cat /proc/sys/kernel/random/uuid)

bazel build //:image_archive

sha256sum bazel-bin/image_archive.tar

cp bazel-bin/image_archive.tar ./image_archive_$RUN_ID.tar
