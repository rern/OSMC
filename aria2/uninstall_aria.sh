#!/bin/bash

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )

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
if ! type aria2 > /dev/null 2>&1; then
	title "$info Aria2 not found."
	exit
fi

title2 "Uninstall Aria2 ..."
# uninstall package #######################################
apt remove -y aria2 nginx bsdtar

# remove files #######################################
title "Remove files ..."
rm -v /etc/nginx/nginx.conf
rm -v /root/.config/aria2/aria2.conf
rm -rfv /usr/share/nginx

# skip if reinstall - pwduninstall.sh re (any argument)
[ $# -ne 0 ] && exit

title2 "Aria2 successfully uninstalled."

rm uninstall_aria.sh
