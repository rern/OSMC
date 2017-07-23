#!/bin/bash

# import heading function
wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

# check installed #######################################
if ! type transmission-daemon &>/dev/null; then
	title "$info Transmission not found."
	exit
fi

title -l = "$bar Uninstall Transmission ..."
# uninstall package #######################################
apt remove -y transmission-daemon transmission-cli

# remove files #######################################
title "Remove files ..."
rm -rfv /etc/transmission-daemon
systemctl disable transmission
rm /etc/systemd/system/transmission.service
systemctl daemon-reload

title -l = "$bar Transmission uninstalled successfully."

rm $0
