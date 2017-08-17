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
sdreload() {
	echo -e '\n'$( tcolor "systemctl daemon-reload" )'\n'
	systemctl daemon-reload
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
	[[ $2 ]] && mntdir=/tmp/$2 || mntdir=/tmp/p$1
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
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
		wget -qN --show-progress https://raw.githubusercontent.com/rern/OSMC/master/_settings/setup.sh
		chmod +x setup.sh
		./setup.sh
	else
		echo -e "\n\e[30m\e[43m ! \e[0m Already setup."
	fi
}
resetrune() {
	. runereset n
	if [[ $success != 1 ]]; then
		echo -e "\e[37m\e[41m ! \e[0m OSMC reset failed."
		return
	fi
	# preload command shortcuts
	mmc 9
	wget -qN --show-progress https://raw.githubusercontent.com/rern/RuneAudio/master/_settings/cmd.sh -P /tmp/p9/etc/profile.d
	
	[[ $ansre == 1 ]] && bootrune
}
hardreset() {
	echo -e "\n\e[30m\e[43m ? \e[0m Reset to virgin OS:"
	echo -e '  \e[36m0\e[m Cancel'
	echo -e '  \e[36m1\e[m Rune'
	echo -e '  \e[36m2\e[m NOOBS: OSMC + Rune'
	echo
	echo -e '\e[36m0\e[m / 1 / 2 ? '
	read -n 1 ans
	echo
	case $ans in
		1) resetrune;;
		2) noobsreset;;
		*) ;;
	esac
}
