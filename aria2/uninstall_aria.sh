#!/bin/bash

# import heading function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh

# check installed #######################################
if ! type aria2c &>/dev/null; then
	titleinfo "Aria2 not found."
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
if mount | grep '/dev/sda1'; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	rm -rv $mnt/aria2/web
else
	rm -rv /root/aria2/web
fi
rm -rv /root/aria2

# skip if reinstall - pwduninstall.sh re (any argument)
[ $# -ne 0 ] && exit

title2 "Aria2 uninstalled successfully."

rm uninstall_aria.sh
