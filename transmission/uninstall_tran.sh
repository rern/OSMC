#!/bin/bash

# import heading function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh
chmod +x f_heading.sh
. f_heading.sh
rm f_heading.sh

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
