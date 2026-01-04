# Create an empty vm with fixed/thick provisioned storage
# $1 is vmid
# $2 is name
# $3 is mac
export vmid=$1
echo $vmid
export disksize=60G
export lvmname="vm-$vmid-disk-0"

# Use production-lvm (regular LVM, not thin)
export vgname="production-lvm-thin"
export storage="production-lvm"

export drivepath="/dev/$vgname/$lvmname"
# Remove existing LV if present
ssh root@pve.gw.lo "lvremove $drivepath -y 2>/dev/null || true"
ssh root@pve.gw.lo "lvcreate --yes --wipesignatures y -L$disksize -n $lvmname $vgname"
ssh root@pve.gw.lo "qm create $1 \
  --machine q35 \
  --name $2 --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16000  \
  --net0 bridge=vmbr0,virtio=$3 \
  --bootdisk scsi0 --scsihw virtio-scsi-single --scsi0 $storage:$lvmname,size=$disksize"
