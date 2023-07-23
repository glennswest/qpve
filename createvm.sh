# Create a empty vm
# $1 is vmid
# $2 is name
# $3 is mac
export vmid=$1
export disksize=200G
echo $vmid
export vmpath="/impulse1/images/$vmid"
export drivepath="/impulse1/images/$vmid/vm-$vmid-disk-0.qcow2"
echo $vmpath
ssh root@pve.gw.lo "mkdir -p $vmpath"
echo $drivepath
ssh root@pve.gw.lo "rm -f $drivepath"
ssh root@pve.gw.lo "qemu-img create -f qcow2 $drivepath $disksize"
ssh root@pve.gw.lo "qm create $1 \
  --machine q35 \
  --name $2 --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16000  \
  --net0 bridge=vmbr0,virtio=$3 \
  --bootdisk scsi0 --scsihw virtio-scsi-single --scsi0 file=impulse1:$1/vm-$1-disk-0.qcow2,iothread=1,size=200G"

