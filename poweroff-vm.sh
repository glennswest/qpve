vmid=`./getvmid.sh $1`
ssh root@pve.gw.lo qm stop ${vmid}

