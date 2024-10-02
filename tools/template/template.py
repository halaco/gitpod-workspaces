import argparse

from tools.template.template_lib import expand_template

parser = argparse.ArgumentParser()
parser.add_argument('template')
parser.add_argument('json')
parser.add_argument('output')
args = parser.parse_args()

print(args.template)
print(args.json)
print(args.output)

expand_template(args.template, args.json, args.output)
