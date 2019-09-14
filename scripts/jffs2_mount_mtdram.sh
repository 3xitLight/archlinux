#!/bin/bash

## Script to mount jffs2 filesystem using mtd kernel modules.
## EMAC, Inc. 2009
#
# Mounting JFFS2 Images using RAM
# One method of mounting JFFS2 images uses the mtdram module to emulate an MTD device using system RAM. 
# This works well for JFFS2 images that are less than approximately 32 MB but will not work for larger 
# images since it requires allocating a large amount of system RAM. The basic steps of this process are as follows:
#
# Load mtdram and mtdblock modules.
# Use the dd command to copy the JFFS2 image to /dev/mtdblock0.
# Mount /dev/mtdblock0 as a JFFS2 filesytem.
# In order to simplify this process, EMAC has created a script which takes the JFFS2 image, mount point, and the erase block size of the image as parameters. The default erase block size for this script is 128 KiB, which is the correct value for most NOR flashes used on EMAC products and some NAND flashes. The eraseblock size can be determined from the contents of /proc/mtd from the system that the image was copied from or created for. For example, if the value of the "erasesize" parameter is 00040000, the erase block size for the device is 256 KiB (0x40000 = 262144 bytes, 262144 / 1024 = 256 KiB). The jffs2_mount_mtdram.sh script is shown below.



if [[ $# -lt 2 ]]
then
    echo "Usage: $0 FSNAME.JFFS2 MOUNTPOINT [ERASEBLOCK_SIZE]"
    exit 1
fi

if [ "$(whoami)" != "root" ]
then
    echo "$0 must be run as root!"
    exit 1
fi

if [[ ! -e $1 ]]
then
    echo "$1 does not exist"
    exit 1
fi

if [[ ! -d $2 ]]
then
    echo "$2 is not a valid mount point"
    exit 1
fi

if [[ "$3" == "" ]]
then
	esize="128"
else
	esize="$3"
fi

# cleanup if necessary
umount /dev/mtdblock0 &>/dev/null
modprobe -r mtdram &>/dev/null
modprobe -r mtdblock &>/dev/null

modprobe mtdram total_size=32768 erase_size=$esize || exit 1
modprobe mtdblock || exit 1
dd if="$1" of=/dev/mtdblock0 || exit 1
mount -t jffs2 /dev/mtdblock0 $2 || exit 1

echo "Successfully mounted $1 on $2"
exit 0
