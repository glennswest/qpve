#!/bin/bash
# Query local Quay registry for mirrored versions and storage usage
#
# Usage: ./registry-status.sh

LOCAL_REGISTRY="registry.gw.lo"
ENV_DIR=".env"
ADMIN_USER="admin"
ADMIN_PASS="admin123"

echo "=== Quay Registry Status ==="
echo ""

# Check if registry is reachable
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' "http://${LOCAL_REGISTRY}/v2/" 2>/dev/null)
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "401" ]; then
    echo "Error: Registry at ${LOCAL_REGISTRY} is not reachable (HTTP $HTTP_CODE)"
    exit 1
fi

echo "Registry: http://${LOCAL_REGISTRY}"
echo ""

# Function to get bearer token for a scope
get_token() {
    local scope="$1"
    curl -s -u "${ADMIN_USER}:${ADMIN_PASS}" \
        "http://${LOCAL_REGISTRY}/v2/auth?service=${LOCAL_REGISTRY}&scope=${scope}" | \
        jq -r '.token' 2>/dev/null
}

# List OpenShift release tags (the main use case)
echo "=== Mirrored OpenShift Releases ==="
RELEASE_REPO="openshift/release"
TOKEN=$(get_token "repository:${RELEASE_REPO}:pull")

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    TAGS_JSON=$(curl -s -H "Authorization: Bearer $TOKEN" \
        "http://${LOCAL_REGISTRY}/v2/${RELEASE_REPO}/tags/list" 2>/dev/null)

    if echo "$TAGS_JSON" | jq -e '.tags' >/dev/null 2>&1; then
        # Count total tags
        TOTAL_TAGS=$(echo "$TAGS_JSON" | jq -r '.tags | length' 2>/dev/null)

        # Extract version tags (format: X.Y.Z-x86_64)
        VERSIONS=$(echo "$TAGS_JSON" | jq -r '.tags[]?' 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+-x86_64$' | sort -V)

        if [ -n "$VERSIONS" ]; then
            echo "Mirrored versions:"
            echo "$VERSIONS" | while read tag; do
                VERSION=$(echo "$tag" | sed 's/-x86_64$//')
                echo "  - OpenShift $VERSION"
            done
            echo ""
            echo "Complete releases: $(echo "$VERSIONS" | wc -l | tr -d ' ')"
            echo "Total image tags: $TOTAL_TAGS"
        else
            echo "No complete release versions found yet"
            if [ "$TOTAL_TAGS" != "0" ] && [ "$TOTAL_TAGS" != "null" ]; then
                echo "Component images tagged: $TOTAL_TAGS"
            else
                echo "(Mirror may still be uploading blobs - manifests are pushed last)"
            fi
        fi
    else
        ERROR=$(echo "$TAGS_JSON" | jq -r '.errors[0].message // .error // "Unknown error"' 2>/dev/null)
        echo "Repository ${RELEASE_REPO}: $ERROR"
    fi
else
    echo "Failed to authenticate to registry"
fi
echo ""

# Try to get storage info via Quay API
echo "=== Storage Usage ==="

# Get organization info for openshift
ORG_TOKEN=$(get_token "repository:openshift/*:pull")
# Quay doesn't expose storage via v2 API, need to check filesystem or use Quay's native API

# Try Quay's native API for repository info
echo "Checking via Quay API..."
API_RESPONSE=$(curl -s -u "${ADMIN_USER}:${ADMIN_PASS}" \
    "http://${LOCAL_REGISTRY}/api/v1/repository?namespace=openshift" 2>/dev/null)

if echo "$API_RESPONSE" | jq -e '.repositories' >/dev/null 2>&1; then
    REPO_COUNT=$(echo "$API_RESPONSE" | jq '.repositories | length')
    echo "Repositories in 'openshift' namespace: $REPO_COUNT"

    # Get more details if repos exist
    if [ "$REPO_COUNT" -gt 0 ]; then
        echo ""
        echo "Repository details:"
        echo "$API_RESPONSE" | jq -r '.repositories[] | "  \(.namespace)/\(.name): \(.tag_count // 0) tags"' 2>/dev/null
    fi
else
    echo "Cannot query Quay API (may need superuser access)"
fi

echo ""
echo "To check storage on registry host:"
echo "  du -sh /var/lib/quay/storage"
echo "  df -h /"
echo ""

# Show a summary of what we know
echo "=== Summary ==="
echo "Registry URL: http://${LOCAL_REGISTRY}"
echo "Status: Online"
if [ -n "$VERSIONS" ]; then
    echo "Mirrored Releases: $(echo "$VERSIONS" | wc -l | tr -d ' ')"
else
    echo "Mirrored Releases: 0 (mirror may be in progress)"
fi
