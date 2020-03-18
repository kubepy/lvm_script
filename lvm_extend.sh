#!/bin/bash

# VARS Setup
EXTEND_PATH=$1
VG_NAME=$2
DEV=$3
LV_NAME=$(df -hTP | awk -v EXTEND_PATH="$EXTEND_PATH" '{if($7==EXTEND_PATH) print $1}')

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
    lvextend -l +100%FREE ${LV_NAME}

    # Resizefs
    resize2fs ${LV_NAME}
    xfs_growfs ${LV_NAME}
else
    # Exit Script
    echo "$DEV has been use!"
    exit 1
fi
