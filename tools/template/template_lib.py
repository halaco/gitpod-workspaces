import json

from jinja2 import Template, Environment, FileSystemLoader


def expand_template(template, values, output):
    with open(values, 'r') as file:
        val = json.load(file)

    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template(template)

    rendered = template.render(val)

    with open(output, 'w') as dst:
        dst.write(template.render(val))
        dst.write('\n')
