#!/bin/bash

docker login

bazel run //workspace-full-bazelisk:workspace-full-bazelisk.push
