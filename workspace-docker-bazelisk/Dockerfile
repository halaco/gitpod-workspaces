FROM gitpod/workspace-base:2024-01-20-13-44-18 as installer

ENV BAZEL_VERSION=6.3.2

USER root

#
# Install bash complation for Bazel
#
#   Add a bazel repository to install bazel and install bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | sudo apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" \
    && apt update \
    && apt-get install -y bazel=${BAZEL_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#   Copy the bash complation file under /opt/bazel/bash_complation.d
RUN mkdir -p /opt/bazel/bash_complation.d \
    && chmod 0755 /opt/bazel/bash_complation.d \
    && cp /etc/bash_completion.d/bazel /opt/bazel/bash_complation.d/bazel.${BAZEL_VERSION}
#   Uninstall bazel and make a symbolic link to the complation file

FROM gitpod/workspace-base:2024-01-20-13-44-18

ENV BAZELISK_VERSION=1.18.0
ENV BAZEL_VERSION=6.3.2

USER root

COPY --from=installer /opt/bazel/bash_complation.d/bazel.${BAZEL_VERSION} /opt/bazel/bash_complation.d/bazel.${BAZEL_VERSION}
RUN ln -s /opt/bazel/bash_complation.d/bazel.${BAZEL_VERSION} /etc/bash_completion.d/bazel

RUN apt update \
    && apt-get install -y docker \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#
# Install bazelisk
#
RUN curl -sSL https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64 -o /usr/bin/bazel \
    && chmod a+x /usr/bin/bazel
