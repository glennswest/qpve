# create-lvm.sh
# lvcreate -V200G -T test-lvm-thin/test-lvm-thin -n vm-600-disk-0
export vmid=$(./getvmid.sh $1)
export lvmname="vm-$vmid-disk-0"
export drivepath="/dev/test-lvm-thin/$lvmname"
echo $drivepath
ssh root@pve.gw.lo "lvremove $drivepath -y"
ssh root@pve.gw.lo "lvcreate -V$2 -T test-lvm-thin/test-lvm-thin -n $lvmname"

