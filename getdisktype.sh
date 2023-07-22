#!/bin/bash
# getdisktype.sh vmname
# Description: Returns qcow or lvm depending on vm
# gwest@Mac-Pro qpve % ./getdisktype.sh boot.gw.lo
# qcow
# gwest@Mac-Pro qpve % ./getdisktype.sh bootstrap.gw.lo
# lvm

export vmid=$(./getvmid.sh $1)
export virtio=$(ssh root@pve.gw.lo "cat /etc/pve/qemu-server/$vmid.conf | grep virtio0: | cut -d \":\" -f1")
export qcow=$(ssh root@pve.gw.lo "cat /etc/pve/qemu-server/$vmid.conf | grep .qcow | cut -d \":\" -f1")
export disktype="none"

if [[ $virtio == "virtio0" ]]; then
   export disktype="lvm"
  fi

if [[ $qcow == "scsi0" ]]; then
   export disktype="qcow"
  fi

echo $disktype
