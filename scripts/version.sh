#!/bin/bash

# version.sh - Shell script to read local version information from git

read -d '' USAGE <<EOF
usage: $0 [srctree]
EOF

# Go to the source directory, defaulting to the current directory
if ! cd "${1:-.}" ; then
  echo "$USAGE" >&2
  exit 1
fi

# If there's a VERSION file present use that
if [ -f VERSION ] ; then
  cat VERSION
else
  # Use git describe to print the string
  git describe --long --tags --dirty --always
fi
