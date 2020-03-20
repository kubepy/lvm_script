# lvm_script

### 1. Extend to specified path with a new disk
#### bash lvm_extend.sh <lv_root_size> <lv_swap_size> <lv_usr_size> <lv_tmp_size> <lv_var_size> <lv_var_crash_size> <lv_home_size> <lv_tivoli_size> <lv_opt_size>
    bash lvm_extend.sh 11 17 11 6 11 17 6 11 6
    
### 2. Create new LV for oracle
#### bash lvm_oracle.sh <lv_oradata_size>
    bash lvm_oracle.sh 10

### 3. Create new LV for mysql
#### bash lvm_mysql.sh <lv_mydata_size>
    bash lvm_mysql.sh 5
