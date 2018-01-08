#!/bin/bash

alias ls='ls -a --color --group-directories-first'
export LS_COLORS='tw=01;34:ow=01;34:ex=00;32:or=31'

tcolor() { 
	echo -e "\e[38;5;10m$1\e[0m"
}

sstt() {
	echo -e '\n'$( tcolor "systemctl status $1" )'\n'
	systemctl status $1
}
ssta() {
	echo -e '\n'$( tcolor "systemctl start $1" )'\n'
	systemctl start $1
}
ssto() {
	echo -e '\n'$( tcolor "systemctl stop $1" )'\n'
	systemctl stop $1
}
sres() {
	echo -e '\n'$( tcolor "systemctl restart $1" )'\n'
	systemctl restart $1
}
srel() {
	echo -e '\n'$( tcolor "systemctl reload $1" )
	systemctl reload $1
}
sdrel() {
	echo -e '\n'$( tcolor "systemctl daemon-reload" )'\n'
	systemctl daemon-reload
}

mmc() {
	[[ $2 ]] && mntdir=/tmp/$2 || mntdir=/tmp/p$1
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
	fi
}

setup() {
	if [[ -e /usr/local/bin/uninstall_motd.sh ]]; then
		echo -e "\n\e[30m\e[43m ! \e[0m Already setup."
	else
		wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh
		chmod +x setup.sh
		./setup.sh
	fi
}
resetrune() {
	. runereset n
	if [[ $success != 1 ]]; then
		echo -e "\e[37m\e[41m ! \e[0m RuneAudio reset failed."
		return
	fi
	# preload command shortcuts
	mmc 9
	wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/cmd.sh -P /tmp/p9/etc/profile.d
	
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
boot() {
	mmc 5
	part=$( sed -n '/name/,/mmcblk/ p' /tmp/p5/installed_os.json | sed '/part/ d; s/\s//g; s/"//g; s/,//; s/name://; s/\/dev\/mmcblk0p//' )
	partarray=( $( echo $part ) )
	partname=${partarray[0]}
	partnum=${partarray[1]}

	ilength=${#partarray[*]}

	echo -e "\n\e[30m\e[43m ? \e[0m Reboot to OS:"
	echo -e '  \e[36m0\e[m Cancel'
	for (( i=0; i < ilength; i++ )); do
		(( $(( i % 2 )) == 0 )) && echo -e "  \e[36m$(( i / 2 + 1 ))\e[m ${partarray[ i ]}"
	done
	echo
	echo 'Which ? '
	read -n 1 ans
	echo
	partboot=$(( ans * 2 + 4 ))
 	if [[ -e /root/reboot.py ]]; then
	 	/root/reboot.py $partboot
		exit
	fi
	
	reboot $partboot
}
