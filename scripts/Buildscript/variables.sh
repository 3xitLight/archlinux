#!/bin/bash

## definde variables
########################################################################
# ${CPU}
CPU=$(lscpu | grep "Model name:" | cut -c 22-)
# ${CORES}
CORES=$(lscpu | grep "^CPU(s)" | cut -c 22-)
# ${BLOCK_DEV}
BLOCK_DEV=$(echo -e "${Yellow}Block Devices: \n${Green}$(lsblk | grep "sd." | awk '{print "'${Red}'> '${Green}'"$1" '${Yellow}'Type: '${Green}'"$6" '${Yellow}'Size: '${Green}'"$4" '${Green}'"$7}' | column -t | sed 's/>/    >/')")
# ${K_VERSION}
K_VERSION=$(uname -srm)
# ${SHELL}
SHELL="$SHELL"
# ${GPU_TEMP}
GPU_TEMP=$(echo -e "$(sensors | grep "temp1:" | cut -c 16-22)")
# ${CPU_TEMP}
CPU_TEMP=$(echo -e "$(sensors | grep "Package id 0:" | cut -c 17-23)")
# ${CPU_CLOCK}
CPU_CLOCK=$(echo -e "$(cat /proc/cpuinfo | grep "cpu MHz" | cut -c 12-15)")
