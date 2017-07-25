#!/bin/bash

alias ls='ls -a --color'

tcolor() { 
	echo -e "\e[38;5;10m$1\e[0m"
}

sstatus() {
	echo -e '\n'$( tcolor "systemctl status $1" )'\n'
	systemctl status $1
}
sstart() {
	echo -e '\n'$( tcolor "systemctl start $1" )'\n'
	systemctl start $1
}
sstop() {
	echo -e '\n'$( tcolor "systemctl stop $1" )'\n'
	systemctl stop $1
}
srestart() {
	echo -e '\n'$( tcolor "systemctl restart $1" )'\n'
	systemctl restart $1
}

mountmmc() {
	mkdir -p /tmp/p$1
	mount /dev/mmcblk0p$1 /tmp/p$1
}
mountrune() {
	mountmmc 9
}

bootosmc() {
	mountmmc 5
	sed -i "s/default_partition_to_boot=./default_partition_to_boot=6/" /tmp/p5/noobs.conf
	reboot
}
bootrune() {
	mountmmc 5
	sed -i "s/default_partition_to_boot=./default_partition_to_boot=8/" /tmp/p5/noobs.conf
	reboot
}

resetrune() {
	umount -l /dev/mmcblk0p9 &> /dev/null
	echo y | mkfs.ext4 /dev/mmcblk0p9 &> /dev/null
	mountmmc 9
	mountmmc 1
	bsdtar -xvf /tmp/p1/os/RuneAudio/root.tar.xz -C /tmp/p9
	
	sed -i "s|^.* /boot |$part1  /boot |" /tmp/p9/etc/fstab
	cp -r /tmp/p1/os/RuneAudio/custom/. /tmp/p9
}
hardreset() {
	echo
	echo "Reset to virgin OS:"
	echo -e '  \e[0;36m0\e[m Cancel'
	echo -e '  \e[0;36m1\e[m OSMC'
	echo -e '  \e[0;36m2\e[m NOOBS: OSMC + Rune'
	echo
	echo -e '\e[0;36m0\e[m / 1 / 2 ? '
	read ans
	case $ans in
		1) resetrune;;
		2) mountmmc 1
			echo -n " forcetrigger" >> /tmp/p1/recovery.cmdline
			reboot;;
		*) ;;
	esac
}
