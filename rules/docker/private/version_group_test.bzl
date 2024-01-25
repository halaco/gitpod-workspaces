load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(":version_group.bzl", "version_set", "compare_version", "sort_versions", "version_group")

def _version_set_test(ctx):
    env = unittest.begin(ctx)

    version_list = version_set("6.3.5")

    asserts.equals(env, 3, len(version_list))
    asserts.equals(env, "6", version_list[0])
    asserts.equals(env, "6.3", version_list[1])
    asserts.equals(env, "6.3.5", version_list[2])

    return unittest.end(env)

version_set_test = unittest.make(_version_set_test)


def _compare_version_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(env, 0, compare_version("6.0.5", "6.0.5"))
    asserts.equals(env, -1, compare_version("6.0.5", "5.0.5"))
    asserts.equals(env, 1, compare_version("6.0.5", "6.1.5"))
    asserts.equals(env, 1, compare_version("6.0.5", "6.0.6"))
    asserts.equals(env, 8, compare_version("7.9.5", "7.17.5"))

    return unittest.end(env)


compare_version_test = unittest.make(_compare_version_test)

def _sort_versions_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(env, ["6.0.5"], sort_versions(["6.0.5"]))
    
    asserts.equals(env, ["6.0.6", "6.0.5"], sort_versions(["6.0.5", "6.0.6"]))
    asserts.equals(env, ["6.0.6", "6.0.5"], sort_versions(["6.0.6", "6.0.5"]))

    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.4", "6.0.5", "6.0.6"]))
    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.6", "6.0.5", "6.0.4"]))
    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.6", "6.0.4", "6.0.5"]))
    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.5", "6.0.4", "6.0.6"]))
    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.4", "6.0.6", "6.0.5"]))
    asserts.equals(env, ["6.0.6", "6.0.5", "6.0.4"], sort_versions(["6.0.5", "6.0.6", "6.0.4"]))

    asserts.equals(env, ["7.0.0", "6.4.0", "6.3.2"], sort_versions(["6.3.2", "6.4.0", "7.0.0"]))
    asserts.equals(env, ["7.0.0", "6.4.1", "6.4.0", "6.3.2"], sort_versions(["6.3.2", "6.4.0", "6.4.1", "7.0.0"]))

    return unittest.end(env)


sort_versions_test = unittest.make(_sort_versions_test)


def _version_group_test(ctx):
    env = unittest.begin(ctx)

    asserts.equals(env, [["7", "7.0", "7.0.0"], ["6", "6.4", "6.4.1"], ["6.4.0"], ["6.3", "6.3.2"]], version_group(["6.3.2", "6.4.0", "6.4.1", "7.0.0"], "7.0.0"))
    asserts.equals(env, [["7", "7.0", "7.0.0"], ["6.4.1"], ["6", "6.4", "6.4.0"], ["6.3", "6.3.2"]], version_group(["6.4.1", "6.3.2", "6.4.0", "7.0.0"], "6.4.0"))
    asserts.equals(env, [["7", "7.0", "7.0.0"], ["6.4", "6.4.1"], ["6.4.0"], ["6", "6.3", "6.3.2"]], version_group(["6.4.1", "6.3.2", "6.4.0", "7.0.0"], "6.3.2"))
    asserts.equals(env, [["7", "7.0", "7.0.0"], ["6", "6.4", "6.4.1"], ["6.4.0"], ["6.3", "6.3.2"]], version_group(["6.3.2", "6.4.0", "6.4.1", "7.0.0"], "6.4.1" ))

    return unittest.end(env)


version_group_test = unittest.make(_version_group_test)


def version_group_test_suite():
    unittest.suite(
        "version_group_tests",
        version_set_test,
        compare_version_test,
        sort_versions_test,
        version_group_test,
    )
