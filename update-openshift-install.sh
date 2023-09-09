export OCP_RELEASE=$1
export LOCAL_REGISTRY='registry.gw.lo:8443'
export LOCAL_REPOSITORY='ocp4/openshift4'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/Users/gwest/gw.lo/pull-secret-registry.txt'
export RELEASE_NAME="ocp-release"
export ARCHITECTURE='x86_64'
export REMOVABLE_MEDIA_PATH='/home/registry/images'
podman login -u init -p YM249uGadAQs1m835CxlW7Jp06knoiTX registry.gw.lo:8443 --tls-verify=false
oc adm release extract --insecure=true -a ${LOCAL_SECRET_JSON} --command=openshift-install "${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE}"
rm -f /usr/local/bin/openshift-install
mv openshift-install /usr/local/bin/openshift-install

