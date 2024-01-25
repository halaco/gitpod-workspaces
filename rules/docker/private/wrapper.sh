#!/bin/bash

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <executable> <output-file> [additional-args...]"
    exit 1
fi

# Extract the first two arguments
executable=$1
output_file=$2

# Shift the arguments so that $@ contains only the additional arguments
shift 2

# Execute the given executable with the remaining arguments
rm -f "$output_file"

"$executable" "$@"

# Check if the execution was successful
if [ $? -eq 0 ]; then
   # popd >> /dev/null
    echo Success
    echo "$@" >> "$output_file"
    exit 0
fi

exit 255
