#!/bin/bash
# getdisktype.sh vmname
# Description: Returns qcow or lvm depending on vm
# gwest@Mac-Pro qpve % ./getdisktype.sh boot.gw.lo
# qcow
# gwest@Mac-Pro qpve % ./getdisktype.sh bootstrap.gw.lo
# lvm

export vmid=$(./getvmid.sh $1)
export xstore=$(ssh root@pve.gw.lo "cat /etc/pve/qemu-server/$vmid.conf | grep scsi0:")
if [[ "$xstore" == *"qcow"* ]]; then
   export disktype="qcow"
  else 
   export disktype="lvm"
  fi

echo $disktype
