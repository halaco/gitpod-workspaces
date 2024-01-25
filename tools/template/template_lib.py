import json

import pystache

def expand_template(template, values, output):
    with open(values, 'r') as file:
        val = json.load(file)

    with open(template, 'r') as src, open(output, 'w') as dst:
        for line in src:

            dst.write(pystache.render(line, val))
    
