export vmid=$(./getvmid.sh $1)
echo $vmid
export drivepath="/impulse1/images/$vmid/vm-$vmid-disk-0.qcow2"
echo $drivepath
ssh root@pve.gw.lo "rm $drivepath"
ssh root@pve.gw.lo "qemu-img create -f qcow2 $drivepath $2"
