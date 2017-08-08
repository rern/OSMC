#!/bin/bash

info='\e[30m\e[43m ! \e[0m'

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
sreload() {
	echo -e '\n'$( tcolor "systemctl stop $1" )
	systemctl stop $1
	echo -e '\n'$( tcolor "systemctl disable $1" )
	systemctl disable $1
	echo -e '\n'$( tcolor "systemctl daemon-reload" )
	systemctl daemon-reload
	echo -e '\n'$( tcolor "systemctl enable $1" )
	systemctl enable $1
	echo -e '\n'$( tcolor "systemctl start $1" )
	systemctl start $1
}

mmc() {
	if [[ ! $( mount | grep p$1 ) ]]; then
		mkdir -p /tmp/p$1
		mount /dev/mmcblk0p$1 /tmp/p$1
	fi
}

bootosmc() {
	/home/osmc/rebootosmc.py
}
bootrune() {
	/home/osmc/rebootrune.py
}

setup() {
	if [[ ! -e /etc/motd.logo ]]; then
		wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh
		chmod +x setup.sh
		./setup.sh
	else
		echo -e "\n$info Already setup."
	fi
}
resetrune() {
	. runereset n
	[[ $? != 0 ]] && return
	
	mmc 9
	wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/cmd.sh -P /tmp/p9/etc/profile.d
	
	yesno "Reboot to Rune:" ansre
	[[ $ansre == 1 ]] && bootrune
}
hardreset() {
	echo -e "\n$info Reset to virgin OS:"
	echo -e '  \e[0;36m0\e[m Cancel'
	echo -e '  \e[0;36m1\e[m Rune'
	echo -e '  \e[0;36m2\e[m NOOBS: OSMC + Rune'
	echo
	echo -e '\e[0;36m0\e[m / 1 / 2 ? '
	read -n 1 ans
	echo
	case $ans in
		1) resetrune;;
		2) noobsreset;;
		*) ;;
	esac
}
