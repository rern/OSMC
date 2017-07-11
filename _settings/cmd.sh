#!/bin/bash

bootosmc() {
	mkdir -p /tmp/p5
	mount /dev/mmcblk0p5 /tmp/p5
	sed -i "s/default_partition_to_boot=./default_partition_to_boot=6/" /tmp/p5/noobs.conf
	reboot
}
bootrune() {
	mkdir -p /tmp/p5
	mount /dev/mmcblk0p5 /tmp/p5
	sed -i "s/default_partition_to_boot=./default_partition_to_boot=8/" /tmp/p5/noobs.conf
	reboot
}
hardreset() {
	echo 'Reset to virgin NOOBS?'
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 ans
	
	if [[ $ans == 1 ]]; then
		mkdir /tmp/p1
		mount /dev/mmcblk0p1 /tmp/p1
		echo -n " forcetrigger" >> /tmp/p1/recovery.cmdline
		reboot
	fi
}
