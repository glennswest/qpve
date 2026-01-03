#!/bin/bash
# Setup authentication for local Quay registry
#
# Usage: ./setup-local-registry-auth.sh [username] [password]
# Example: ./setup-local-registry-auth.sh admin admin123
#
# Stores credentials in .env/local-registry-auth.json

LOCAL_REGISTRY="registry.gw.lo"
ENV_DIR=".env"

mkdir -p "$ENV_DIR"

if [ -z "$1" ]; then
    read -p "Username for ${LOCAL_REGISTRY}: " USERNAME
else
    USERNAME="$1"
fi

if [ -z "$2" ]; then
    read -s -p "Password for ${LOCAL_REGISTRY}: " PASSWORD
    echo ""
else
    PASSWORD="$2"
fi

# Create base64 encoded auth
AUTH=$(echo -n "${USERNAME}:${PASSWORD}" | base64)

# Create local registry auth file
cat > "${ENV_DIR}/local-registry-auth.json" << EOF
{
  "auths": {
    "${LOCAL_REGISTRY}": {
      "auth": "${AUTH}",
      "email": ""
    }
  }
}
EOF

echo "Created ${ENV_DIR}/local-registry-auth.json"
echo ""
echo "Test connection with:"
echo "  curl -u ${USERNAME}:PASSWORD http://${LOCAL_REGISTRY}/v2/_catalog"
