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
lv_opt=$9

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
disk_sda_total_size=$((${boot_fixed_size}+${lv_root_fixed_size}+${lv_swap_fixed_size}+${lv_usr_fixed_size}+${lv_tmp_fixed_size}+${lv_var_fixed_size}+${lv_var_crash_fixed_size}+${lv_home_fixed_size}+${lv_tivoli_fixed_size}+$lv_opt_fixed_size}))
new_disk_dev="/dev/sdb"

# Format For The New Disk
fdisk_command_for_new_disk_dev="$(cat <<-EOF
n
p
1
w
EOF
)"
fdisk ${new_disk_dev} <<< "${fdisk_command_for_new_disk_dev}"
partprobe ${new_disk_dev}
sleep 3s
pvcreate ${new_disk_dev}1 -y
vgextend VolGroup ${new_disk_dev}1
lvextend -l +${lv_root_size}G lv_root
lvextend -l +${lv_swap_size}G lv_swap
lvextend -l +${lv_usr_size}G lv_usr
lvextend -l +${lv_tmp_size}G lv_tmp
lvextend -l +${lv_var_size}G lv_var
lvextend -l +${lv_var_crash_size}G lv_var_crash
lvextend -l +${lv_home_size}G lv_home
lvextend -l +${lv_tivoli_size}G lv_tivoli
lvextend -l +${lv_opt_size}G lv_opt
