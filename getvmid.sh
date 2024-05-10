export vmid="$(ssh root@pve.gw.lo "qm list | grep $1 | awk '{print \$1}'")"
if [ -z "${vmid}" ]; then
   export vmid=$1
   fi
echo $vmid
