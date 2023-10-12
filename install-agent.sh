./poweroff-all-vms.sh
./erase-all-vms.sh
#./pull-install.sh $1
rm -r -f gw
mkdir gw
cp install-config-agent.yaml gw/install-config.yaml
cp agent-config.yaml gw
cd gw
openshift-install agent create image
scp agent.x86_64.iso root@192.168.1.29:/var/lib/vz/template/iso/coreos-x86_64.iso
cd ..
./poweron-all-vms.sh 
openshift-install --dir=gw agent wait-for bootstrap-complete               
openshift-install --dir=gw agent wait-for install-complete               

