#!/bin/bash

docker login

bazel run //workspace-mysql-bazelisk:workspace-mysql-bazelisk.push
