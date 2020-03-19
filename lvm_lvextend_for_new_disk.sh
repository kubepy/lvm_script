#!/bin/bash

# Input Vars
lv_root_size=$1
lv_swap_size=$2
lv_usr_size=$3
lv_tmp_size=$4
lv_var_size=$5
lv_var_crash_size=$6
lv_home_size=$7
lv_tivoli_size=$8
lv_opt_size=$9

# Fixed Vars
boot_fixed_size=1
lv_root_fixed_size=10
lv_swap_fixed_size=16
lv_usr_fixed_size=10
lv_tmp_fixed_size=5
lv_var_fixed_size=10
lv_var_crash_fixed_size=16
lv_home_fixed_size=5
lv_tivoli_fixed_size=10
lv_opt_fixed_size=5

# Extend Disk Vars
lv_root_extend_size=$((lv_root_size-lv_root_fixed_size))
lv_swap_extend_size=$((lv_swap_size-lv_swap_fixed_size))
lv_usr_extend_size=$((lv_usr_size-lv_usr_fixed_size))
lv_tmp_extend_size=$((lv_tmp_size-lv_tmp_fixed_size))
lv_var_extend_size=$((lv_var_size-lv_var_fixed_size))
lv_var_crash_extend_size=$((lv_var_crash_size-lv_var_crash_fixed_size))
lv_home_extend_size=$((lv_home_size-lv_home_fixed_size))
lv_tivoli_extend_size=$((lv_tivoli_size-lv_tivoli_fixed_size))
lv_opt_extend_size=$((lv_opt_size-lv_opt_fixed_size))

# Loop list for lvextend
lv_extend_size_list="$(cat <<-EOF
${lv_root_extend_size} /dev/mapper/VolGroup-lv_root
${lv_swap_extend_size} /dev/mapper/VolGroup-lv_swap
${lv_usr_extend_size} /dev/mapper/VolGroup-lv_usr
${lv_tmp_extend_size} /dev/mapper/VolGroup-lv_tmp
${lv_var_extend_size} /dev/mapper/VolGroup-lv_var
${lv_var_crash_extend_size} /dev/mapper/VolGroup-lv_var_crash
${lv_home_extend_size} /dev/mapper/VolGroup-lv_home
${lv_tivoli_extend_size} /dev/mapper/VolGroup-lv_tivoli
${lv_opt_extend_size} /dev/mapper/VolGroup-lv_opt
EOF
)"

# Other Vars
new_disk_dev="/dev/sdb"
if [ "$(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/' | sed 's/el//')" -gt "6" ]
then
    lvm_fstype="xfs"
else
    lvm_fstype="ext4"
fi

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
   vgextend VolGroup ${new_disk_dev}1

   while read lv_extend_size lv_name
   do
       if [ "$lv_extend_size" -gt "0" ]
       then
          echo "############################################"
          echo "Extend ${lv_extend_size}G for ${lv_name}"
          lvextend -L +${lv_extend_size}G ${lv_name}
          if [ "$lvm_fstype" == "ext4" ]
          then
              resize2fs ${lv_name}
          elif [ "$lvm_fstype" == "xfs" ]
          then
              xfs_growfs ${lv_name}
          fi
          echo "############################################"
       fi
   done <<< "${lv_extend_size_list}"
else
   echo "$new_disk_dev has been use. Exit!"
   exit 1
fi
