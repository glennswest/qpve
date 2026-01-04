# create-lvm.sh
# Creates fixed/thick provisioned LVM volume
export vmid=$(./getvmid.sh $1)
export lvmname="vm-$vmid-disk-0"

# Use production-lvm (regular LVM, not thin)
export vgname="production-lvm-thin"
export storage="production-lvm"

export drivepath="/dev/$vgname/$lvmname"
echo $drivepath
ssh root@pve.gw.lo "lvremove $drivepath -y 2>/dev/null || true"
ssh root@pve.gw.lo "lvcreate --yes --wipesignatures y -L$2 -n $lvmname $vgname"

