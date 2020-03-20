#!/bin/bash

# Input Vars
lv_mydata_size=$1
new_disk_dev="/dev/sdb"

# Fixed Vars
lv_mysql_fixed_size=15

# Other Vars
vg_name=Oraclevg
if [ "$(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/' | sed 's/el//')" -gt "6" ]
then
    lvm_fstype="xfs"
else
    lvm_fstype="ext4"
fi

# Loop list for lvcreate
lv_extend_size_list="$(cat <<-EOF
${lv_mysql_fixed_size} lv_mysql /dev/mapper/$vg_name-lv_mysql /mysql
${lv_mydata_size} lv_mydata /dev/mapper/$vg_name-lv_mydata /mydata
EOF
)"

# Format For The New Disk
ls ${new_disk_dev}[1-9]
if [ "$?" != "0" ]
then
    fdisk_command_for_new_disk_dev="$(cat <<-EOF
n
p
1


t
8e
w
EOF
   )"
   fdisk ${new_disk_dev} <<< "${fdisk_command_for_new_disk_dev}"
   partprobe ${new_disk_dev}
   sleep 5s
   pvcreate ${new_disk_dev}1 -y
   vgcreate $vg_name ${new_disk_dev}1

   while read lv_extend_size lv_name lv_path mount_path
   do
       echo "############################################"
       echo "Extend ${lv_extend_size}G for ${lv_name}"
       lvcreate -L +${lv_extend_size}G -n ${lv_name} ${vg_name}
       if [ "$lvm_fstype" == "ext4" ]
       then
           mkfs.ext4 ${lv_path}
           if [ "$?" == "0" ]
           then
               mkdir ${mount_path}
               echo "${lv_path} ${mount_path} ${lvm_fstype} defaults 0 0" >> /etc/fstab
               mount -av
           fi
       elif [ "$lvm_fstype" == "xfs" ]
       then
           mkfs.xfs ${lv_path}
           if [ "$?" == "0" ]
           then
               mkdir ${mount_path}
               echo "${lv_path} ${mount_path} ${lvm_fstype} defaults 0 0" >> /etc/fstab
               mount -av
           fi

       fi
   done <<< "${lv_extend_size_list}"
else
   echo "$new_disk_dev has been used. Exit!"
   exit 1
fi
