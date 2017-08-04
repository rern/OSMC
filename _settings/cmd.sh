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

setup() {
	if [[ ! -e /etc/motd.logo ]]; then
		wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh
		chmod +x setup.sh
		./setup.sh
	else
		echo "Already setup."
	fi
}
resetrune() {
	wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
	timestart
	
	title -l = "$bar Rune reset ..."
	umount -l /dev/mmcblk0p9 &> /dev/null
	echo -e "$bar Format partition ..."
	echo y | mkfs.ext4 /dev/mmcblk0p9 &> /dev/null
	mountmmc 9
	mountmmc 1
	
	if ! type bsdtar &>/dev/null; then
		echo -e "$bar Install bsdtar ..."
		apt update
		apt install -y bsdtar
	fi
	pathrune=/tmp/p9
	bsdtar -xvf /tmp/p1/os/RuneAudio/root.tar.xz -C $pathrune \
		--exclude=./srv/http/.git \
		--exclude=./usr/include \
		--exclude=./usr/lib/libgo.* \
		--exclude=./usr/lib/python2.7/test \
		--exclude=./usr/lib/python3.5 \
		--exclude=./usr/share/{doc,gtk-doc,info,man}
	
	# from partition_setup.sh
	sed -i -e 's|^.* /boot |/dev/mmcblk0p8  /boot |
	' -e '/^#/ d
	' -e 's/\s\+0\s\+0\s*$//
	' $pathrune/etc/fstab
	
	cp -r /tmp/p1/os/RuneAudio/custom/. $pathrune
	
	wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/cmd.sh -P $pathrune/etc/profile.d
	
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
