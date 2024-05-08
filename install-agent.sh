./pull-install.sh $1
rm -r -f gw
mkdir gw
cp install-config-agent.yaml gw/install-config.yaml
cp agent-config.yaml gw
cd gw
openshift-install agent create image
rm ~/.kube/config
cp auth/kubeconfig ~/.kube/config
scp agent.x86_64.iso root@192.168.1.29:/var/lib/vz/template/iso/coreos-x86_64.iso
cd ..
./poweroff-all-vms.sh
./erase-all-vms.sh
./poweron-vm.sh control0.gw.lo
./poweron-vm.sh control1.gw.lo
./poweron-vm.sh control2.gw.lo
echo "Give control nodes head start"
sleep 120
./poweron-vm.sh worker0.gw.lo
#./poweron-vm.sh worker1.gw.lo
#./poweron-vm.sh worker2.gw.lo
openshift-install --dir=gw agent wait-for bootstrap-complete               
openshift-install --dir=gw agent wait-for install-complete               

