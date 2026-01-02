#!/bin/bash
# Install OpenShift using local mirrored registry
#
# Usage: ./install-local.sh <version>
# Example: ./install-local.sh 4.18.30
#
# Prerequisites:
# - Release mirrored to registry.gw.lo using mirror-release.sh

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
LOCAL_RELEASE="${LOCAL_REGISTRY}/${LOCAL_REPO}:${VERSION}-x86_64"
PULL_SECRET="${ENV_DIR}/pullsecret-combined.json"

# Check for combined pull secret
if [ ! -f "$PULL_SECRET" ]; then
    echo "Error: Combined pull secret not found: $PULL_SECRET"
    echo "Run mirror-release.sh first."
    exit 1
fi

# Clean up SSH known_hosts for cluster nodes
echo "Cleaning up SSH known_hosts entries for cluster nodes..."
ssh-keygen -R bootstrap.gw.lo 2>/dev/null || true
ssh-keygen -R control0.gw.lo 2>/dev/null || true
ssh-keygen -R control1.gw.lo 2>/dev/null || true
ssh-keygen -R control2.gw.lo 2>/dev/null || true
ssh-keygen -R worker0.gw.lo 2>/dev/null || true
ssh-keygen -R worker1.gw.lo 2>/dev/null || true
ssh-keygen -R worker2.gw.lo 2>/dev/null || true
echo "SSH known_hosts cleanup complete."

# Pull openshift-install from the mirrored release
echo "Extracting openshift-install from mirrored release..."
oc adm release extract \
    --command=openshift-install \
    --registry-config="${PULL_SECRET}" \
    "${LOCAL_RELEASE}"

mv openshift-install /usr/local/bin/openshift-install
chmod +x /usr/local/bin/openshift-install

# Extract oc client as well
echo "Extracting oc client from mirrored release..."
oc adm release extract \
    --command=oc \
    --registry-config="${PULL_SECRET}" \
    "${LOCAL_RELEASE}"

mv oc /usr/local/bin/oc
chmod +x /usr/local/bin/oc

# Create install directory
rm -rf gw
mkdir gw

# Create install-config with local registry
echo "Creating install-config.yaml for local registry..."
cat > gw/install-config.yaml << 'BASECONFIG'
apiVersion: v1
baseDomain: lo
compute:
- hyperthreading: Enabled
  architecture: amd64
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: gw
networking:
  clusterNetworks:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  - cidr: fd01::/48
    hostPrefix: 64
  machineNetwork:
  - cidr: 192.168.1.0/24
  - cidr: 2001:db8::/120
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
  - fd02::/112
platform:
  none: {}
fips: false
BASECONFIG

# Add imageContentSources for local registry
cat >> gw/install-config.yaml << EOF
imageContentSources:
- mirrors:
  - ${LOCAL_REGISTRY}/${LOCAL_REPO}
  source: quay.io/openshift-release-dev/ocp-release
- mirrors:
  - ${LOCAL_REGISTRY}/${LOCAL_REPO}
  source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
EOF

# Add pull secret from combined file
echo -n "pullSecret: '" >> gw/install-config.yaml
cat "$PULL_SECRET" | tr -d '\n' >> gw/install-config.yaml
echo "'" >> gw/install-config.yaml

# Add SSH key
echo "sshKey: $(cat ~/.ssh/id_rsa.pub)" >> gw/install-config.yaml

# Keep a backup of the install-config
cp gw/install-config.yaml gw/install-config.yaml.bak

echo ""
echo "=== Creating ignition configs ==="
openshift-install create ignition-configs --dir=gw

# Copy worker.ign locally for manual worker additions
cp gw/worker.ign ~ 2>/dev/null || true

# Setup kubeconfig
rm -f ~/.kube/config
mkdir -p ~/.kube
cp gw/auth/kubeconfig ~/.kube/config

# Copy ignition configs to boot server
scp -r gw/* root@boot.gw.lo:/tftp || { echo "Failed to copy ignition configs to boot server"; exit 1; }

# Power off and erase VMs
./poweroff-all-vms.sh
sleep 5
./erase-all-vms.sh
sleep 3

# Start CSR approval early - runs throughout entire install
echo "Starting automatic CSR approval..."
echo 1 > .approvecsr.dat
./approvecsr.sh &
CSR_PID=$!

# Power on all VMs in parallel for faster startup
echo "Powering on all VMs in parallel..."
./poweron-vm.sh bootstrap.gw.lo &
./poweron-vm.sh control0.gw.lo &
./poweron-vm.sh control1.gw.lo &
./poweron-vm.sh control2.gw.lo &
./poweron-vm.sh worker0.gw.lo &
./poweron-vm.sh worker1.gw.lo &
./poweron-vm.sh worker2.gw.lo &
wait

echo ""
echo "=== Waiting for bootstrap to complete ==="
echo "Images will be pulled from: ${LOCAL_REGISTRY}"
echo ""
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
./poweroff-vm.sh bootstrap.gw.lo

openshift-install --dir=gw wait-for install-complete --log-level debug

# Stop CSR approval loop
echo 0 > .approvecsr.dat
wait $CSR_PID 2>/dev/null

echo ""
echo "=== Installation Complete ==="
echo "Cluster installed using local registry: ${LOCAL_REGISTRY}"
