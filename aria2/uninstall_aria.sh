#!/bin/bash

# import heading function
wget -qN --show-progress https://github.com/rern/title_script/master/raw/title.sh; . title.sh; rm title.sh

# check installed #######################################
if [[ ! -e /usr/local/bin/uninstall_aria.sh ]]; then
	title "$info Aria2 not found."
	exit
fi

title -l = "$bar Uninstall Aria2 ..."
systemctl disable aria2
systemctl stop aria2
rm /etc/systemd/system/aria2.service
systemctl daemon-reload
# uninstall package #######################################
apt remove -y aria2

# remove files #######################################
echo -e "$bar Remove files ..."
if mount | grep -q '/dev/sda1'; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	rm -rv $mnt/aria2/web
else
	rm -rv /root/aria2/web
fi
rm -rv /root/aria2

# skip if reinstall - pwduninstall.sh re (any argument)
[ $# -ne 0 ] && exit

title -l = "$bar Aria2 uninstalled successfully."

rm $0
