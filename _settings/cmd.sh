#!/bin/bash

bootosmc() {
	echo 6 > /sys/module/bcm2709/parameters/reboot_part
	/var/www/command/rune_shutdown
	reboot
}
bootrune() {
	echo 8 > /sys/module/bcm2709/parameters/reboot_part
	/var/www/command/rune_shutdown
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
		/var/www/command/rune_shutdown
		reboot
	fi
}
