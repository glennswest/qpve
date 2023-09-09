rm -r -f gw
mkdir gw
cp install-config.yaml gw
openshift-install create ignition-configs --dir=gw
cp ~/gw.lo/gw/worker.ign ~
rm -f ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
rm ~/.kube/config
cp gw/auth/kubeconfig ~/.kube/config
scp -r gw/* root@boot.gw.lo:/tftp
./poweroff-all-vms.sh
sleep 5
./erase-all-vms.sh
sleep 5
# ./poweron-all-vms.sh
./poweron-vm.sh bootstrap.gw.lo
sleep 300
./poweron-vm.sh control0.gw.lo
./poweron-vm.sh control1.gw.lo
./poweron-vm.sh control2.gw.lo
./poweron-vm.sh worker0.gw.lo
openshift-install --dir=gw wait-for bootstrap-complete --log-level debug
./poweroff-vm.sh bootstrap.gw.lo
sleep 30
./poweron-vm.sh worker1.gw.lo
./poweron-vm.sh worker2.gw.lo
openshift-install --dir=gw wait-for install-complete --log-level debug





