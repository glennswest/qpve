#!/bin/bash
# Mirror OpenShift release to local Quay registry
#
# Usage: ./mirror-release.sh <version>
# Example: ./mirror-release.sh 4.18.30
#
# Prerequisites:
# - oc CLI installed
# - Quay registry running at registry.gw.lo
# - Local registry credentials in .env/local-registry-auth.json

set -e

LOCAL_REGISTRY="registry.gw.lo"
LOCAL_REPO="openshift/release"
ENV_DIR=".env"

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 4.18.30"
    exit 1
fi

VERSION="$1"

# Upstream release image
UPSTREAM_RELEASE="quay.io/openshift-release-dev/ocp-release:${VERSION}-x86_64"

# Local release image path
LOCAL_RELEASE="${LOCAL_REGISTRY}/${LOCAL_REPO}:${VERSION}-x86_64"

echo "=== Mirroring OpenShift ${VERSION} to ${LOCAL_REGISTRY} ==="
echo ""
echo "Source: ${UPSTREAM_RELEASE}"
echo "Destination: ${LOCAL_RELEASE}"
echo ""

# Check for local registry credentials
if [ ! -f "${ENV_DIR}/local-registry-auth.json" ]; then
    echo "Error: Local registry credentials not found."
    echo "Run first: ./setup-local-registry-auth.sh <username> <password>"
    exit 1
fi

# Check for upstream pull secret
if [ ! -f "pullsecret.json" ]; then
    echo "Error: pullsecret.json not found."
    exit 1
fi

# Merge pull secrets
echo "Merging pull secrets..."
mkdir -p "$ENV_DIR"
jq -s '.[0] * .[1]' pullsecret.json "${ENV_DIR}/local-registry-auth.json" > "${ENV_DIR}/pullsecret-combined.json"
echo "Created ${ENV_DIR}/pullsecret-combined.json"

PULL_SECRET="${ENV_DIR}/pullsecret-combined.json"

echo ""
echo "Starting mirror operation..."
echo "This may take 30-60 minutes depending on network speed."
echo ""

# Mirror the release
oc adm release mirror \
    --from="${UPSTREAM_RELEASE}" \
    --to="${LOCAL_REGISTRY}/${LOCAL_REPO}" \
    --to-release-image="${LOCAL_RELEASE}" \
    --registry-config="${PULL_SECRET}"

echo ""
echo "=== Mirror Complete ==="
echo ""
echo "Release mirrored to: ${LOCAL_RELEASE}"
echo ""
echo "To install using the mirrored release, run:"
echo "  ./install-local.sh ${VERSION}"
