#!/bin/bash

# version.sh - Shell script to read local version information from git

read -d '' USAGE <<EOF
usage: $0 [srctree]
EOF

# Go to the source directory, defaulting to the current directory
if ! cd "${1:-.}" ; then
  echo "$USAGE" >&2
  exit
fi

# Use git describe to print the string
git describe --long --tags --dirty --always
