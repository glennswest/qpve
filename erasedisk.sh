export disktype=$(./getdisktype.sh $1)
if [[ $disktype == "lvm" ]]; then
   echo "lvm erase"
   ./create-lvm.sh $1 200G
  fi
if [[ $disktype == "qcow" ]]; then
   echo "qcow erase"
   ./create-qcow.sh $1 200G
  fi
if [[ $disktype == "none" ]]; then
   echo "DANGER: Unknown disk type - STOP NOW"
  fi
