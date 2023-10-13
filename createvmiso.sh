# Create a empty vm
# $1 is vmid
# $2 is name
# $3 is mac
export vmid=$1
echo $vmid
export disksize=200G
export lvmname="vm-$vmid-disk-0"
export drivepath="/dev/test-lvm-thin/$lvmname"
ssh root@pve.gw.lo "lvcreate -V$disksize -T test-lvm-thin/test-lvm-thin -n $lvmname"
ssh root@pve.gw.lo "qm create $1 \
  --machine q35 \
  --name $2 --numa 0 --ostype l26 \
  --cpu cputype=host --cores 8 --sockets 1 \
  --memory 17000  \
  --net0 bridge=vmbr0,virtio=$3 \
  --ide2 local:iso/coreos-x86_64.iso,media=cdrom \
  --bootdisk scsi0 --scsihw virtio-scsi-single --scsi0 test-lvm-thin:$lvmname,size=200G,cache=writeback,discard=on,iothread=1" \
