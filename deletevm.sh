vmid=`./getvmid.sh $1`
lvmname="vm-$vmid-disk-0"
vgname="production-lvm-thin"
drivepath="/dev/$vgname/$lvmname"

# Destroy VM first (this removes disk reference from config)
ssh root@pve.gw.lo "qm destroy ${vmid} --purge 2>/dev/null || true"

# Then remove LV if it exists
ssh root@pve.gw.lo "lvremove $drivepath -y 2>/dev/null || true"
