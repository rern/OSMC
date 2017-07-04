#!/bin/bash

line2=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' = )
line=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - )
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )

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
if ! type aria2c &>/dev/null; then
	title "$info Aria2 not found."
	exit
fi

title2 "Uninstall Aria2 ..."
systemctl disable aria2
systemctl stop aria2
rm /etc/systemd/system/aria2.service
systemctl daemon-reload
# uninstall package #######################################
apt remove -y aria2

# remove files #######################################
title "Remove files ..."
rm -rv /root/.aria2
rm -r /var/www/html/aria2

# skip if reinstall - pwduninstall.sh re (any argument)
[ $# -ne 0 ] && exit

echo 'Nginx still installed.'
echo 'Remove: apt purge nginx nginx-common nginx-full'
titleend "Aria2 uninstalled successfully."

rm uninstall_aria.sh
