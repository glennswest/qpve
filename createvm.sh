# Create a empty vm
# $1 is vmid
# $2 is name
# $3 is mac
export vmid=$1
echo $vmid
export disksize=200G
export lvmname="vm-$vmid-disk-0"

# Use production-lvm-thin for all VMs
export lvmpool="production-lvm-thin"

export drivepath="/dev/$lvmpool/$lvmname"
ssh root@pve.gw.lo "lvcreate -V$disksize -T $lvmpool/$lvmpool -n $lvmname"
ssh root@pve.gw.lo "qm create $1 \
  --machine q35 \
  --name $2 --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16000  \
  --net0 bridge=vmbr0,virtio=$3 \
  --bootdisk scsi0 --scsihw virtio-scsi-single --scsi0 $lvmpool:$lvmname,size=200G"
