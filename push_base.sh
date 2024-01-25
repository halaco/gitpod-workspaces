#!/bin/bash

docker login

bazel run //workspace-base-bazelisk:workspace-base-bazelisk.push
