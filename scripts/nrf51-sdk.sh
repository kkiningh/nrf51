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
6.1.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v6.x.x/nrf51_sdk_v6_1_0_b2ec2e6.zip
6.0.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v6.x.x/nrf51_sdk_v6_0_0_43681.zip
5.2.0 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v5.x.x/nrf51_sdk_v5_2_0_39364.zip
4.4.2 https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/nrf51_sdk_v4_4_2_33551.zip
EOF

read -d '' USAGE <<EOF
usage: $0 version [outfile]
  version must be valid nRF51 SDK version number in the form X.X.X
  outfile defaults to "nRF51_SDK_vX.X.X" where X.X.X is the sdk version string
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
  # Give local names to parameters for clarity
  local SDK_VERSION="$1"
  local SDK_PATH="$2"

  # Search the list of URLs for the specified file
  local URL=$(echo "${SDK_URLS}" | awk '$1 == "'${SDK_VERSION}'" {print $2}' | head -n 1)
  if [ -z "${URL}" ] ; then
    err "No download URL found for SDK version '${SDK_VERSION}'"
    exit 1
  fi

  # Download the SDK
  local SDK_ZIP="${SDK_PATH}.zip"
  if [ ! -f "${SDK_ZIP}" ] ; then
    if ! curl -o "${SDK_ZIP}" "${URL}" --progress-bar ; then
      err "cURL failed to download version '${SDK_VERSION}' from Nordic"
      err "Tried URL ${URL}"
      exit 1
    fi
  fi

  # Extract the SDK
  if [ ! -d "${SDK_PATH}" ] ; then
    if ! unzip -qq -o -d "${SDK_PATH}" "${SDK_ZIP}" ; then
      err "unzip failed to extract SDK version '${SDK_VERSION}' from the ZIP file"
      err "Tried unzipping ZIP file ${SDK_ZIP}"
      exit 1
    fi
  fi
}

###
# Main
###

# If no arguments were given, print the usage string
if [ $# -eq 0 ] || [ $# -gt 2 ] ; then
  err "${USAGE}"
  exit 1
fi

# Download the sdk version given on the command line
sdk_get "$1" "${2:-nRF51_SDK_v$1}"
