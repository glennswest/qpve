rm -r -f gw
mkdir gw
cp install-config.yaml gw
openshift-install create ignition-configs --dir=gw
cp ~/gw.lo/gw/worker.ign ~
rm -f ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
rm ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
scp gw/* root@store.gw.lo:/volume1/tftp
./poweroff-all-vms.sh
sleep 5
./erase-all-vms.sh
sleep 5
./poweron-all-vms.sh
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
./poweroff-vm.sh bootstrap.gw.lo
./poweron-vm.sh worker0.gw.lo
./poweron-vm.sh worker1.gw.lo
./poweron-vm.sh worker2.gw.lo
openshift-install --dir=gw wait-for install-complete --log-level debug
openshift-install --dir=gw wait-for install-complete --log-level debug





