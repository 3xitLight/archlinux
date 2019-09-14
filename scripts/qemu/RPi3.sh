#bin/sh
qemu-system-arm \
				-kernel kernel-qemu-4.4.34-jessie \
				-hda openwrt-r49395-brcm2708-bcm2708-rpi-ext4-sdcard.img \
				-cpu arm1176 \
				-m 256 \
				-M versatilepb \
				-serial stdio \
				-append "root=/dev/sda2 rootfstype=ext4 rootwait rw panic=0 console=ttyAMA0"
