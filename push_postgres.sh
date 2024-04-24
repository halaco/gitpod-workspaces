#!/bin/bash

docker login

bazel run //workspace-postgres-bazelisk:workspace-postgres-bazelisk.push
