#export theversion="4.12.30"
export wanted_version=$1

# Function to compare versions (returns 0 if v1 == v2, 1 if v1 > v2, -1 if v1 < v2)
version_compare() {
    local v1=$1
    local v2=$2

    if [ "$v1" = "$v2" ]; then
        echo 0
        return
    fi

    local IFS=.
    local i ver1=($v1) ver2=($v2)

    # Fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo 1
            return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            echo -1
            return
        fi
    done
    echo 0
}

# Find the latest available version closest to wanted version
find_latest_version() {
    local wanted=$1
    local verx=$(echo $wanted | cut -d '.' -f 1)
    local very=$(echo $wanted | cut -d '.' -f 2)
    local mver=$verx.$very

    echo "Looking for versions in $mver series closest to $wanted..." >&2

    # Get available versions in the major.minor series
    local available_versions
    available_versions=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/amd64/dependencies/rhcos/$mver/" | \
        grep -E 'href="[0-9]+\.[0-9]+\.[0-9]+/"' | \
        sed 's/.*href="\([^"]*\)".*/\1/' | \
        sed 's|/$||' | \
        sort -V)

    if [ -z "$available_versions" ]; then
        echo "No versions found in $mver series" >&2
        return 1
    fi

    local best_version=""
    local best_comparison=999
    local latest_version=""

    # Find the version closest to wanted version (preferring newer versions)
    while IFS= read -r version; do
        if [ -z "$version" ]; then continue; fi

        local comparison=$(version_compare "$version" "$wanted")

        # If exact match, use it immediately
        if [ "$comparison" -eq 0 ]; then
            echo "$version"
            return 0
        fi

        # Always track the latest version as fallback
        if [ -z "$latest_version" ] || [ "$(version_compare "$version" "$latest_version")" -gt 0 ]; then
            latest_version="$version"
        fi

        # For newer versions (comparison > 0), prefer the smallest one
        if [ "$comparison" -gt 0 ]; then
            if [ "$best_comparison" -ne 1 ] || [ -z "$best_version" ] || [ "$(version_compare "$version" "$best_version")" -lt 0 ]; then
                best_version="$version"
                best_comparison=1
            fi
        # For older versions (comparison < 0), prefer the largest one
        elif [ "$comparison" -lt 0 ]; then
            if [ "$best_comparison" -ne -1 ] || [ -z "$best_version" ] || [ "$(version_compare "$version" "$best_version")" -gt 0 ]; then
                best_version="$version"
                best_comparison=-1
            fi
        fi
    done <<< "$available_versions"

    # If no best version found, use the latest available
    if [ -z "$best_version" ] && [ -n "$latest_version" ]; then
        best_version="$latest_version"
    fi

    if [ -n "$best_version" ]; then
        echo "$best_version"
        return 0
    else
        echo "No suitable version found" >&2
        return 1
    fi
}

# Find the actual version to use
export theversion=$(find_latest_version "$wanted_version")
if [ $? -ne 0 ] || [ -z "$theversion" ]; then
    echo "Failed to find a suitable version for $wanted_version"
    exit 1
fi

echo "Using version: $theversion (requested: $wanted_version)"

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

