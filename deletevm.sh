vmid=`./getvmid.sh $1`
./erasedisk.sh $1
ssh root@pve.gw.lo qm destroy ${vmid}


