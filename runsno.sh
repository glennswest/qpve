rm -r -f gw
mkdir gw
cp install-config-sno.yaml gw/install-config.yaml
openshift-install create ignition-configs --dir=gw
cp ~/gw.lo/gw/worker.ign ~
rm -f ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
rm ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
scp gw/* root@store.gw.lo:/volume1/tftp
./poweroff-vm.sh node.sno.gw.lo
sleep 5
./erasedisk.sh node.sno.gw.lo
sleep 5
./poweron-vm.sh node.sno.gw.lo
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
openshift-install --dir=gw wait-for install-complete --log-level debug
openshift-install --dir=gw wait-for install-complete --log-level debug





