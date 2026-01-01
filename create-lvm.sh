# create-lvm.sh
# lvcreate -V200G -T test-lvm-thin/test-lvm-thin -n vm-600-disk-0
export vmid=$(./getvmid.sh $1)
export lvmname="vm-$vmid-disk-0"

# Determine LVM thin pool based on node type
if [[ $1 == control* ]]; then
    export lvmpool="test-lvm-thin"
else
    export lvmpool="services-lvm-thin"
fi

export drivepath="/dev/$lvmpool/$lvmname"
echo $drivepath
ssh root@pve.gw.lo "lvremove $drivepath -y"
ssh root@pve.gw.lo "lvcreate -V$2 -T $lvmpool/$lvmpool -n $lvmname"

