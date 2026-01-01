# qpve
## Proxmox tools for working with multiple vm testing
In a environment where several vm are needed for one test environment, being able to power them on or off is useful
These are designed to work with proxmox 8+

## Bootstrap Configuration Access

The bootstrap.ign file is accessible via both HTTP and TFTP protocols from the boot server (boot.gw.lo):

### HTTP Access
- **URL**: `http://boot.gw.lo/bootstrap.ign`
- **Service**: nginx on port 80
- **Document Root**: `/var/lib/tftpboot/`

### TFTP Access
- **Service**: tftpd-hpa on port 69 UDP
- **Server**: boot.gw.lo
- **File Location**: `/var/lib/tftpboot/bootstrap.ign`

### File Management
- Source files are maintained in `/tftp/` directory on boot.gw.lo
- Files are copied (not symlinked) to `/var/lib/tftpboot/` for both HTTP and TFTP access
- TFTP daemon requires real files, not symlinks, for security reasons
- Files should be owned by appropriate service users (www-data for HTTP, tftp for TFTP)

### Deployment
Use `scp -r gw/* root@boot.gw.lo:/tftp` to deploy ignition files, then copy to web root as needed.

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


