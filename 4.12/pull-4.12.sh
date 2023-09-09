export theversion="4.12.30"
export basepath="https://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.12/${theversion}"
export tfilename="rhcos-${theversion}-x86_64"
ext="-live-kernel-x86_64";       wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-live-initramfs.x86_64.img";wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-live-rootfs.x86_64.img";   wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-metal.x86_64.raw.gz";wget --no-check-certificate ${basepath}/${tfilename}${ext}       -O rhcos-${theversion}${ext}

echo ${basepath}/${tfilename}${ext}

ext="-live-kernel-x86_64"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall.vmlinuz
ext="-live-initramfs.x86_64.img"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall-initramfs.img
ext="-live-rootfs.x86_64.img";  scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall-rootfs.img
ext="-metal.x86_64.raw.gz"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcos-bios.raw.gz
