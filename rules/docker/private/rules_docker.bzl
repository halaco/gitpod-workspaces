load("@bazel_skylib//lib:paths.bzl", "paths")
load(":version_group.bzl", "version_group")

DockerToolchainInfo = provider(
    fields = {
        'command_path' : 'path to docker command',
    }
)

def _docker_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        dockerinfo = DockerToolchainInfo(
            command_path = ctx.attr.command_path,
        ),
    )
    return [toolchain_info]

docker_toolchain = rule(
    implementation = _docker_toolchain_impl,
    attrs = {
        "command_path":attr.string(),
    },
)


DockerfileInfo = provider(
    fields = {
        'filename': '',
        'prefix' : 'tags defined for this image',
        'path': '',
    }
)


def _docker_template_impl(ctx):
    dockerfile = ctx.outputs.docker_path
    values_json = json.encode(ctx.attr.values)

    json_file = ctx.actions.declare_file(paths.join(ctx.attr.prefix, ctx.label.name + ".json"))
    ctx.actions.write(json_file, values_json)

    args = ctx.actions.args()
    args.add(ctx.files.template[0])
    args.add(json_file)
    args.add(dockerfile)

    ctx.actions.run(
        outputs = [dockerfile],
        inputs = [ctx.files.template[0], json_file],
        arguments = [args],
        executable = ctx.executable._template_engine,
        mnemonic = "DockerTemplate",
    )

    return [
        DefaultInfo(files = depset([dockerfile])),
        DockerfileInfo(
            filename = ctx.attr.dockerfile,
            prefix = ctx.attr.prefix,
            path = dockerfile,
        ),
    ]


docker_template = rule(
    implementation = _docker_template_impl,
    attrs = {
        "template": attr.label(
            allow_files = [".mustache"],
        ),
        "values": attr.string_dict(),
        "dockerfile": attr.string(),
        "prefix": attr.string(),
        "_template_engine": attr.label(
            default = Label("//tools/template"),
            executable = True,
            cfg = "exec",
        ),
    },
    outputs = {
        "docker_path": paths.join("%{prefix}", "%{dockerfile}"),
    },
)


DockerImageInfo = provider(
    fields = {
        'tags' : 'tags defined for this image',
    }
)


def _docker_image_impl(ctx):
    toolchain = ctx.toolchains["//rules/docker:toolchain_type"].dockerinfo

    prefix = ctx.attr.dockerfile[DockerfileInfo].prefix

    output = ctx.actions.declare_file(prefix + "_done")

    args = ctx.actions.args()
    args.add(toolchain.command_path)
    args.add(output.path)
    args.add("build")
    for tag in ctx.attr.image_tags:
        args.add("-t")
        args.add(tag)
    args.add(ctx.file.dockerfile.dirname)

    # Execute docker build command with the given Dockefile
    ctx.actions.run(
        outputs = [output],
        inputs = [ctx.file.dockerfile],
        tools = [ctx.file._wrapper],
        arguments = [args],
        executable = ctx.file._wrapper.path,
        mnemonic = "DockerBuild",
    )

    return [
        DefaultInfo(files = depset([output])),
        DockerImageInfo(tags = ctx.attr.image_tags),
    ]


docker_image = rule(
    implementation = _docker_image_impl,
    attrs = {
        "dockerfile": attr.label(
            allow_single_file = True,
        ),
        "prefix": attr.string(),
        "image_tags": attr.string_list(),
        "_wrapper": attr.label(
            default = "wrapper.sh",
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        )
    },
    toolchains = ["//rules/docker:toolchain_type"],
)


def _docker_push_impl(ctx):
    toolchain = ctx.toolchains["//rules/docker:toolchain_type"].dockerinfo

    # Generate a shell script that push all tags to dockerhub.

    tags = []
    success_files = []
    for dep in ctx.attr.deps:
        tags.extend(dep[DockerImageInfo].tags)
        for f in dep[DefaultInfo].files.to_list():
            print(f.path)
        success_files.extend(dep[DefaultInfo].files.to_list())

    script = ["#!/bin/bash"]
    for tag in tags:
        script.append(toolchain.command_path + " push " + tag)

    ctx.actions.write(ctx.outputs.push_sh, "\n".join(script), is_executable=True)

    return [
        DefaultInfo(
            executable = ctx.outputs.push_sh,
            files = depset(success_files),
        ),
    ]


docker_push = rule(
    implementation = _docker_push_impl,
    attrs = {
        "deps": attr.label_list(providers=[DockerImageInfo]),
    },
    outputs = {
        "push_sh": "%{name}.sh",
    },
    executable = True,
    toolchains = ["//rules/docker:toolchain_type"],
)


def docker_images(name, workspace_name, tag_base, workspace_version, docker_file_template, current_bazel_vesrion, bazel_versions, bazelisk_vesion):

    images = []
    version_groups = version_group(bazel_versions, current_bazel_vesrion)

    for version_list in version_groups:
        version = version_list[-1]
        print(version)
        prefix = "bazel." + version
        dockerfile_name = "Dockerfile"
        template_step_name = name + ".template." + version 

        docker_template(
            name = template_step_name,
            template = docker_file_template,
            dockerfile = dockerfile_name,
            prefix = prefix,
            values = {
                "workspace": workspace_name,
                "workspace_version": workspace_version,
                "bazel_version": version,
                "bazelisk_version": bazelisk_vesion,
            }
        )

        tags = []

        for sub_version in version_list:
            tags.append(tag_base + ":bazel." + sub_version + "-" + workspace_version)
            tags.append(tag_base + ":bazel." + sub_version + "-latest")

        if version == current_bazel_vesrion:
            tags.append(tag_base + ":latest")

        image_step_name = name + ".image." + version 

        docker_image(
            name = image_step_name,
            dockerfile = template_step_name,
            image_tags = tags,
        )
        images.append(image_step_name)

    docker_push(
        name = name + ".push",
        deps = images,
    )
