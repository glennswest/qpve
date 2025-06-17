#export theversion="4.12.30"
export theversion=$1
export verx=$(echo $theversion | cut -d '.' -f 1)
export very=$(echo $theversion | cut -d '.' -f 2)
export mver=$verx.$very
export basepath="https://mirror.openshift.com/pub/openshift-v4/amd64/dependencies/rhcos/$mver/${theversion}"
export tfilename="rhcos-${theversion}-x86_64"
ext="-live-kernel-x86_64";       wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-live-initramfs.x86_64.img";wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-live-rootfs.x86_64.img";   wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-${theversion}${ext}
ext="-metal.x86_64.raw.gz";wget --no-check-certificate ${basepath}/${tfilename}${ext}       -O rhcos-${theversion}${ext}
ext="-live.x86_64.iso";wget --no-check-certificate ${basepath}/${tfilename}${ext}       -O rhcos-${theversion}${ext}
#rhcos-4.14.15-x86_64-live.x86_64.iso

echo ${basepath}/${tfilename}${ext}

ext="-live-kernel-x86_64"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall.vmlinuz
ext="-live-initramfs.x86_64.img"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall-initramfs.img
ext="-live-rootfs.x86_64.img";  scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcosinstall-rootfs.img
ext="-metal.x86_64.raw.gz"; scp  rhcos-${theversion}${ext} root@boot.gw.lo:/tftp/rhcos-bios.raw.gz
ext="-live.x86_64.iso"; scp  rhcos-${theversion}${ext} root@pve.gw.lo:/var/lib/vz/template/iso/coreos-x86_64.iso

