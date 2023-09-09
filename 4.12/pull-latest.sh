wget --quiet https://releases-rhcos-art.cloud.privileged.psi.redhat.com/storage/releases/rhcos-4.9/builds.json
export basepath=`jq .builds[0].id < builds.json | tr -d '"' `
echo $basepath
export buildid=`jq .buildid < builds.json | tr -d '"' `
echo $buildid
export tfilename="rhcos-${buildid}"
echo $tfilename

echo ${basepath}/${tfilename}${ext} -O rhcos-4.9${ext}
ext="-live-kernel-x86_64";       wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-4.9${ext}
ext="-live-initramfs.x86_64.img";wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-4.9${ext}
ext="-live-rootfs.x86_64.img";   wget --no-check-certificate ${basepath}/${tfilename}${ext} -O rhcos-4.9${ext}
ext="-metal.x86_64.raw.gz";wget --no-check-certificate ${basepath}/${tfilename}${ext}       -O rhcos-4.9${ext}


ext="-live-kernel-x86_64"; scp  rhcos-4.9${ext} root@store.gw.lo:/volume1/tftp/rhcosinstall.vmlinuz
ext="-live-initramfs.x86_64.img"; scp  rhcos-4.9${ext} root@store.gw.lo:/volume1/tftp/rhcosinstall-initramfs.img
ext="-live-rootfs.x86_64.img";  scp  rhcos-4.9${ext} root@store.gw.lo:/volume1/tftp/rhcosinstall-rootfs.img
ext="-metal.x86_64.raw.gz"; scp  rhcos-4.9${ext} root@store.gw.lo:/volume1/tftp/rhcos-bios.raw.gz


