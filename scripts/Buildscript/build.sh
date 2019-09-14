#!/bin/bash

## Colorize and add text parameters
########################################################################
## Text color variables
########################
# ${txtund}
txtund=$(tput sgr 0 1)          # Underline
# ${txtbld}
txtbld=$(tput bold)             # Bold
# ${bldblk}
bldblk=${txtbld}$(tput setaf 0) # Black
# ${bldred}
bldred=${txtbld}$(tput setaf 1) # red
# ${bldgrn}
bldgrn=${txtbld}$(tput setaf 2) # green
# ${bldylw}
bldylw=${txtbld}$(tput setaf 3) # Yellow
# ${bldblu}
bldblu=${txtbld}$(tput setaf 4) # blue
# ${bldmgt}
bldmgt=${txtbld}$(tput setaf 5) # Magenta
# ${bldcya}
bldcya=${txtbld}$(tput setaf 6) # cyan
# ${bldwht}
bldwht=${txtbld}$(tput setaf 7) # white
# ${txtrst}
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}
#######################################################################
#######################################################################
#######################################################################
## definde variables
#######################################################################
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

####################
## SET ENVIRONMENT:
####################

export DEFCONFIG="kombatkernel_defconfig"
export KERNELDIR="/run/media/xnn/HDD/01-Andr0id/Nethunter_Oneplus2/02-Kernels/01-LOS_android_kernel_oneplus_msm8994"
export WORKDIR="$KERNELDIR/0-out"
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE="/run/media/xnn/HDD/toolchains/LINARO-aarch64-linux-gnu/bin/aarch64-linux-gnu-"
# export CROSS_COMPILE="/run/media/xnn/HDD/toolchains/GOOGLE-aarch64-linux-android-4.9/bin/aarch64-linux-android-"
HOST="Blackbyte_Inc"
export HOSTNAME="Blackbyte_Inc"
####################
# time counter to 0
SECONDS=0

export ELAPSED="Elapsed time: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"

#################
## ASCII GREETER
#################
echo "	"
echo " ${bldylw}	 ____  __.                         .__ ___.         .__.__       .__	"
echo " ${bldylw}	|    |/ _|___________  ____   ____ |  |\_ |__  __ __|__|  |    __| _	"
echo " ${bldylw}	|      <_/ __ \_  __ \/    \_/ __ \|  | | __ \|  |  \  |  |   / __ |	"
echo " ${bldylw}	|    |  \  ___/|  | \/   |  \  ___/|  |_| \_\ \  |  /  |  |__/ /_/ |	"
echo " ${bldylw}	|____|__ \___  >__|  |___|  /\___  >____/___  /____/|__|____/\____ |	"
echo " ${bldylw}	        \/   \/           \/     \/         \/                    \/	"
echo ""
echo " ${bldylw}	${CPU} ${txtrst}"
echo " ${bldylw}	Physical cores: ${CORES} ${txtrst}"
echo " ${bldylw}	Current temp: ${CPU_TEMP} ${txtrst}"
#
echo ""
echo ""
echo ""
echo " ### Setting up environment..."
echo ""
cd $KERNELDIR || return
sleep 2

####################
## CLEAN SOURCE:
####################
echo " "
echo -e "### cleaning source from the last build..."
echo " "
#
if [ -e $WORKDIR ]; then
		rm -r $WORKDIR
		make clean && make mrproper
		mkdir $KERNELDIR/0-out
else
		make clean && make mrproper
		mkdir $KERNELDIR/0-out
fi

#######################################################################################################
####################
# SET DEFCONFIG
#####################

echo " "
echo -e "###  setting $DEFCONFIG "
echo " "
sleep 1

make $DEFCONFIG

#######################################################################################################
####################
# BUILD KERNEL
####################
echo " "
echo -e "${bldcya}  start building Kernel ${txtrst}"
echo " "

# script -q $WORKDIR/Compile.log

make -j"$(nproc --all)" > $WORKDIR/compile.log 1>&2

#######################################################################################################
##################################
#  COPY NEEDED FILES TO WORKDIR  #
##################################

if [ -e $KERNELDIR/arch/arm64/boot/Image.gz-dtb ]; then

	cp -v $KERNELDIR/arch/arm64/boot/Image.gz-dtb $WORKDIR
	make INSTALL_MOD_PATH=$WORKDIR modules
	make INSTALL_MOD_PATH=$WORKDIR modules_install
	mkdir -p $WORKDIR/modules
	# cp -a "$(find . "-name" *.ko -print |grep -v initramfs)" $WORKDIR/modules/
	 rm $KERNELDIR/arch/arm64/boot/zImage-dtb
	echo " "
	echo " ${bldgrn} kernel build succesful! ${txtrst} "
	echo " "
	echo " ${bldylw} $ELAPSED  ${txtrst}"
	echo " "

	else

		echo ""
		echo " ${bldred} build failed! ${txtrst}"
		echo ""
		echo " ${bldylw} $ELAPSED  ${txtrst}"
		echo ""

    sleep 5

		exit

fi
