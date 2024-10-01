load("@bazel_skylib//lib:new_sets.bzl", "sets")

def version_set(version):
    version_parts = version.split('.')
    version_list = []
    version_valiation = ""

    for part in version_parts:
        version_valiation = ".".join([version_valiation, part])
        version_list.append(version_valiation[1:])

    return version_list


def compare_version(version_a, version_b):
    version_a_parts = version_a.split('.')
    version_b_parts = version_b.split('.')

    for part_a, part_b in zip(version_a_parts, version_b_parts):
        diff = int(part_b) - int(part_a)
        if diff != 0:
            return diff

    return 0


def sort_versions(versions):
    sorted = []

    for version in versions:
        if len(sorted) == 0:
            sorted = [version]
        else:
            new = []
            inserted = False
            for old in sorted:
                if not inserted and compare_version(old, version) > 0:
                    new.append(version)
                    inserted = True
                new.append(old)
            if not inserted:
                new.append(version)  

            sorted = new

    return sorted


def version_group(versions, current_version):
    sorted = sort_versions(versions)
    current_version_set = version_set(current_version)

    used = sets.make()
    sets.insert(used, current_version_set[0])
    sets.insert(used, current_version_set[1])
    group = []
    for version in sorted:
        not_used = []
        if version == current_version:
            not_used.append(current_version_set[0])
            not_used.append(current_version_set[1])
        for sub in version_set(version):
            if not sets.contains(used, sub):
                not_used.append(sub)
                sets.insert(used, sub)

        group.append(not_used)

    return group
