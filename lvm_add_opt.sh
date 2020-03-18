#!/bin/bash

# VARS Setup
EXTEND_PATH=$1
VG_NAME=$2
DEV=$3
FSTYPE=$4
LV_NAME=lv_opt

# Check Disk
ls ${DEV}[1-9]
if [ "$?" != "0" ]
then
    # Format New Disk
    FDISK_NEW_DISK="$(cat <<-EOF
n
p
1


w
EOF
    )"
    fdisk ${DEV} <<< "${FDISK_NEW_DISK}"
    partprobe ${DEV}
    sleep 3s

    # Add LVM
    pvcreate ${DEV}1 -y
    vgextend ${VG_NAME} ${DEV}1
    lvcreate -l +100%FREE -n ${LV_NAME} ${VG_NAME}
    
    # Format LV
    mkfs.${FSTYPE} /dev/mapper/${VG_NAME}-${LV_NAME}

    # Mount FSTAB
    if [ "$?" == "0" ]
    then
        echo "/dev/mapper/${VG_NAME}-${LV_NAME} ${EXTEND_PATH} ${FSTYPE} defaults 0 0" >> /etc/fstab
        echo "/dev/mapper/${VG_NAME}-${LV_NAME} has been added to /etc/fstab"
        mount -av
    fi

else
    # Exit Script
    echo "$DEV has been use!"
    exit 1
fi
