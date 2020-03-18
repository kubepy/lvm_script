# lvm_script

### 1. Extend to some path for a new disk
#### bash lvm_extend.sh <extend_path> <vg_name> <dev_path>
    bash lvm_extend.sh / rhel /dev/sdb

### 2. Add lv_opt to /opt for a new disk
#### bash lvm_add_opt.sh /opt <vg_name> <dev_path> <fs_type>
    bash lvm_add_opt.sh /opt rhel /dev/sdb xfs
