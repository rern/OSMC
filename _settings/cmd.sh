#!/bin/bash

alias ls='ls -a --color --group-directories-first'
export LS_COLORS='tw=01;34:ow=01;34:ex=00;32:or=31'

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
	wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
	timestart
	
	umount -l /dev/mmcblk0p9 &> /dev/null
	title "$bar Format partition ..."
	echo y | mkfs.ext4 /dev/mmcblk0p9 &> /dev/null
	mountmmc 9
	mountmmc 1
	if ! type bsdtar &>/dev/null; then
		title "Install bsdtar ..."
		apt update
		apt install -y bsdtar
	fi
	bsdtar -xvf /tmp/p1/os/RuneAudio/root.tar.xz -C /tmp/p9
	
	file=/tmp/p9/etc/fstab
	sed -i -e "s|^.* /boot |$part1 /boot |
	" -e '/^#/ d
	' $file
	# format header and column
	mv $file{,.original}
	sed '1 i\#device mount type option dump pass' $file'.original' | column -t > $file
	w=$( wc -L < $file )                 # widest line
	hr=$( printf "%${w}s\n" | tr ' ' - ) # horizontal line
	sed -i '1 a\#'$hr $file
	
	cp -r /tmp/p1/os/RuneAudio/custom/. /tmp/p9
	
	wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/cmd.sh -P /etc/profile.d
	
	timestop
	title -l = "$bar Rune reset successfully."
	
	yesno "$info Reboot to Rune:" ansre
	[[ $ansre == 1 ]] && bootrune
}
hardreset() {
	echo -e '\nReset to virgin OS:'
	echo -e '  \e[0;36m0\e[m Cancel'
	echo -e '  \e[0;36m1\e[m Rune'
	echo -e '  \e[0;36m2\e[m NOOBS: OSMC + Rune'
	echo
	echo -e '\e[0;36m0\e[m / 1 / 2 ? '
	read -n 1 ans
	echo
	case $ans in
		1) resetrune;;
		2) mountmmc 1
			echo -n " forcetrigger" >> /tmp/p1/recovery.cmdline
			reboot;;
		*) ;;
	esac
}
