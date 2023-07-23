# qpxe 
## Proxmox tools for working with multiple vm testing
In a environment where several vm are needed for one test enviornmnet, being able to power them on or off is useful
These are designed to work with proxmox 8+

### Erasedisk.sh
Automatically recreate disk for a vm by name. Checks type and the calls create-lvm.sh or create-qcow2

Example:
./erasedisk.sh control0.gw.lo

### Create testvm
This creates a pxe bootable vm with 200Gig of thin storage on impulse1 as a compress qcow file. This technique
is faster than cloning after testing

Example:
./createvm.sh 706 worker2.gw.lo 00:50:56:1f:32:32

### Example of power on and off
gwest@Mac-Pro qpve % ./poweron-vm.sh bootstrap.gw.lo 
gwest@Mac-Pro qpve % ./poweroff-vm.sh bootstrap.gw.lo
gwest@Mac-Pro qpve % ./erasedisk.sh bootstrap.gw.lo 
lvm erase
/dev/pve/vm-700-disk-0
  Logical volume "vm-700-disk-0" successfully removed.
  Logical volume "vm-700-disk-0" created.
gwest@Mac-Pro qpve % 


