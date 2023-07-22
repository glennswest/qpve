# create-lvm.sh
export vmid=$(./getvmid.sh $1)
export lvmname="vm-$vmid-disk-0"
export drivepath="/dev/pve/$lvmname"
echo $drivepath
ssh root@pve.gw.lo "lvremove $drivepath -y"
ssh root@pve.gw.lo "lvcreate -n $lvmname -V $2 pve/data"
