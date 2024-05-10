# $1 is vm name
# $2 is size
# #3 is drive number
export vmid=$(./getvmid.sh $1)
export driveno=$3
echo $vmid
export drivepath="/impulse1/images/$vmid/vm-$vmid-disk-$driveno.qcow2"
echo $drivepath
ssh root@pve.gw.lo "rm -f $drivepath"
ssh root@pve.gw.lo "qemu-img create -f qcow2 $drivepath $2"
