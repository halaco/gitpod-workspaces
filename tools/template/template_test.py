import unittest

from tools.template.template_lib import expand_template

def compare_files(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        # Read the contents of each file
        f1_lines = f1.readlines()
        f2_lines = f2.readlines()

    # Compare the length first to quickly catch different sized files
    if len(f1_lines) != len(f2_lines):
        print(len(f1_lines))
        print(len(f2_lines))
        return False

    # Compare line by line
    for line1, line2 in zip(f1_lines, f2_lines):
        if line1 != line2:
            print(f"'{line1}'")
            print(f"'{line2}'")
            return False

    return True


class TemplateTest(unittest.TestCase):

    def test_expand_template(self):
        template = "tools/template/dockerfile.jinja"
        values = "tools/template/values.json"
        output = "tools/template/dockerfile"
        golden = "tools/template/dockerfile.golden"

        expand_template(template, values, output)

        self.assertTrue(compare_files(output, golden))


if __name__ == '__main__':
    unittest.main()
