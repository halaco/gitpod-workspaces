#!/bin/bash

docker login

bazel run //workspace-base-bazelisk:workspace-base-bazelisk.push
bazel run //workspace-docker-bazelisk:workspace-docker-bazelisk.push
bazel run //workspace-full-bazelisk:workspace-full-bazelisk.push
bazel run //workspace-postgres-bazelisk:workspace-postgres-bazelisk.push
