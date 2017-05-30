#!/bin/bash

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

# functions #######################################
title2() {
	echo -e "\n$line2\n"
	echo -e "$bar $1"
	echo -e "\n$line2\n"
}
title() {
	echo -e "\n$line"
	echo $1
	echo -e "$line\n"
}

# check installed #######################################
if ! type transmission-daemon &>/dev/null; then
	title "$info Transmission not found."
	exit
fi

title2 "Uninstall Transmission ..."
# uninstall package #######################################
apt remove -y transmission-daemon transmission-cli

# remove files #######################################
title "Remove files ..."
rm -rfv /etc/transmission-daemon
rm /etc/systemd/system/transmission.service
[[ ! -e /usr/share/transmission ]] && rm -r /usr/share/transmission
systemctl daemon-reload

title2 "Transmission successfully uninstalled."

rm uninstall_tran.sh
