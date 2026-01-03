echo "Installing nmstatectl for 4.14 support"
rm -r -f temp
mkdir temp
cd temp
wget https://github.com/nmstate/nmstate/releases/download/v2.2.16/nmstatectl-macos-x64.zip
unzip nmstatectl-macos-x64.zip
mv nmstatectl /usr/local/bin
chmod +x /usr/local/bin/nmstatectl
cd ..
rm -r -f temp

#export theversion="4.12.30"
export theversion=$1
export vinfo=$(openshift-install version | head -n 1)
export installedversion=$(echo $vinfo | cut -d ' ' -f 2)
export releaseimage=$(openshift-install version | grep "release image" || echo "")
echo $installedversion
# Check version matches AND release image is from quay.io (not local registry)
if [ "$1" == "$installedversion" ] && echo "$releaseimage" | grep -q "quay.io"
then
   exit
fi
export verx=$(echo $theversion | cut -d '.' -f 1)
export very=$(echo $theversion | cut -d '.' -f 2)

export mver=$verx.$very
export basepath=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/${theversion}
rm -r -f temp
mkdir temp
cd temp
wget --no-check-certificate ${basepath}/openshift-install-mac.tar.gz -O openshift-install.tar.gz
tar xvzf openshift-install.tar.gz
mv openshift-install /usr/local/bin
wget --no-check-certificate ${basepath}/openshift-client-mac.tar.gz -O openshift-client.tar.gz
tar xvzf openshift-client.tar.gz
mv oc /usr/local/bin
mv kubectl /usr/local/bin
cd ..
rm -r -f temp
