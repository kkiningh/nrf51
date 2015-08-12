#!/bin/bash

# nrf51-sdk.sh - Shell script to download a given nRF51 SDK version from Nordic
# This is useful for projects that depend on the SDK but cannot distribute it
# (i.e. for license reasons)

###
# Globals
###

read -d '' SDK_URLS <<EOF
9.0.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v9.x.x/nRF51_SDK_9.0.0_2e23562.zip
8.1.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v8.x.x/nRF51_SDK_8.1.0_b6ed55f.zip
8.0.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v8.x.x/nRF51_SDK_8.0.0_5fc2c3a.zip
7.2.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v7.x.x/nRF51_SDK_7.2.0_cf547b5.zip
7.1.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v7.x.x/nRF51_SDK_7.1.0_372d17a.zip
7.0.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v7.x.x/nRF51_SDK_7.0.0_2ab6a52.zip
EOF

# Base directory for all SDK files to go
SDK_BASE_DIR="nRF51_SDK"

read -d '' USAGE <<EOF
usage: $0 [-f] version...
  -f force install even if it overwrites exisiting SDK
  version must be version number >=7.0.0 in the form X.X.0
EOF

###
# Functions
###

# Print a message on stderr
err () {
  echo "$@" >&2
}

# Download a specified version of the SDK
sdk_get () {
  # Search the list of URLs for the specified file
  local URL=$(echo "$SDK_URLS" | awk '$1 == "'$1'" {print $2}' | head -n 1)
  if [ -z "$URL" ] ; then
    err "No download URL found for SDK version '$1'"
    exit 2
  fi

  # Create the SDK base directory if it doesn't already exist
  mkdir -p "$SDK_BASE_DIR"

  # Download the SDK
  local SDK_ZIP="$SDK_BASE_DIR/$1.zip"
  if [ ! -f "$SDK_ZIP" ] || [ "$FORCE" ] ; then
    if ! curl -o "$SDK_ZIP" $URL --progress-bar ; then
      err "cURL failed to download version '$1' from Nordic"
      err "Tried URL $URL"
      exit 3
    fi
  fi

  # Extract the SDK
  local SDK_DIR="$SDK_BASE_DIR/$1"
  if [ ! -d "$SDK_DIR" ] || [ "$FORCE" ] ; then
    if ! unzip -qq -o -d "$SDK_DIR" "$SDK_ZIP" ; then
      err "unzip failed to extract SDK version '$1' from the ZIP file"
      err "Tried ZIP file $SDK_ZIP"
      exit 4
    fi
  fi
}

###
# Main
###

# If no arguments were given, print the usage string
if [ $# -eq 0 ] ; then
  err "$USAGE"
  exit 1
fi

# Parse any options
while [ "$1" ] ; do
  case "$1" in
    -f) FORCE=1
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Download each sdk version given on the command line
for arg in "$@" ; do
  sdk_get "$arg"
done
