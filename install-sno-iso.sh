export ARCH=x86_64
export OCP_VERSION=$1
./pull-install.sh $1

rm -r -f wip
mkdir wip
cd wip
openshift-install version
rm *.gz
cd ..
ISO_URL=$(openshift-install coreos print-stream-json | grep location | grep $ARCH | grep iso | cut -d\" -f4)
echo $ISO_URL
curl -L $ISO_URL -o rhcos-live.iso
scp rhcos-live.iso root@dev.gw.lo:/root/inplace-install
rm -r -f gw
mkdir gw
cp install-config-sno.yaml gw/install-config.yaml
openshift-install create single-node-ignition-config --dir=gw
scp -r gw/* root@dev.gw.lo:/root/inplace-install
ssh root@dev.gw.lo "cd inplace-install;coreos-installer iso ignition embed -fi bootstrap-in-place-for-live-iso.ign rhcos-live.iso"
scp root@dev.gw.lo:/root/inplace-install/rhcos-live.iso root@pve.gw.lo:/impulse1/template/iso

ls -l gw
rm -f ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
rm ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config

scp -r gw/* root@boot.gw.lo:/tftp
./poweroff-vm.sh node.sno.gw.lo
sleep 5
./erasedisk.sh node.sno.gw.lo
sleep 5
./poweron-vm.sh node.sno.gw.lo
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
openshift-install --dir=gw wait-for install-complete --log-level debug
