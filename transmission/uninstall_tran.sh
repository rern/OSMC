#!/bin/bash

line2=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' = )
line=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - )
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

# functions #######################################
title2() {
	echo $line2
	echo -e "$bar $1"
	echo $line2
}
title() {
	echo $line
	echo -e "$1"
	echo $line
}
titleend() {
	echo -e "\n$1"
	echo $line
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
systemctl disable transmission
rm /etc/systemd/system/transmission.service
systemctl daemon-reload

echo 'Nginx still installed.'
echo 'Remove: apt purge nginx nginx-common nginx-full'
titleend "Transmission uninstalled successfully."

rm uninstall_tran.sh
