ssh root@pve.gw.lo "qm list | grep $1 | awk '{print \$1}'"

