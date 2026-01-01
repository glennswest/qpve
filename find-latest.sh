#!/bin/bash

# Usage: ./find-latest.sh 4.18
# Finds the latest z-stream version for a given major.minor version

if [ -z "$1" ]; then
    echo "Usage: $0 <version>" >&2
    echo "Example: $0 4.18" >&2
    exit 1
fi

input_version=$1

# Extract major.minor version (handles both "4.18" and "4.18.0" formats)
verx=$(echo $input_version | cut -d '.' -f 1)
very=$(echo $input_version | cut -d '.' -f 2)
mver=$verx.$very

# Query OpenShift mirror for available installer versions in this series
available_versions=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/" | \
    grep -E "href=\"$mver\.[0-9]+/\"" | \
    sed 's/.*href="\([^"]*\)".*/\1/' | \
    sed 's|/$||' | \
    sort -V)

if [ -z "$available_versions" ]; then
    echo "Error: No versions found in $mver series" >&2
    exit 1
fi

# Get the latest version (last line after sorting)
latest_version=$(echo "$available_versions" | tail -n 1)

echo "$latest_version"
