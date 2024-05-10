# Create a empty vm
# $1 is vmid
# $2 is name
# $3 is mac
export vmid=$1
echo $vmid
export drivepath="/impulse1/images/$vmid/"
echo $drivepath
ssh root@pve.gw.lo "rm -r -f $drivepath;mkdir -p $drivepath"
./create-qcow-drive.sh $vmid 100M 0   
./create-qcow-drive.sh $vmid 100M 1   
./create-qcow-drive.sh $vmid 100M 2   
./create-qcow-drive.sh $vmid 100M 3   
./create-qcow-drive.sh $vmid 100M 4   
ssh root@pve.gw.lo "qm create $1 \
  --machine q35 \
  --name $2 --numa 0 --ostype l26 \
  --cpu cputype=host --cores 4 --sockets 1 \
  --memory 16000  \
  --net0 bridge=vmbr0,virtio=$3 \
  --bootdisk scsi0 \
  --scsihw virtio-scsi-single \
  --scsi0 impulse1:$1/vm-$1-disk-0.qcow2 \
  --scsi1 impulse1:$1/vm-$1-disk-1.qcow2 \
  --scsi2 impulse1:$1/vm-$1-disk-2.qcow2 \
  --scsi3 impulse1:$1/vm-$1-disk-3.qcow2 \
  --scsi4 impulse1:$1/vm-$1-disk-4.qcow2"
