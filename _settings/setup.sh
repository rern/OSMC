#!/bin/bash

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )

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

title2 "Set apt cache to usb drive ..."
#################################################################################
rm -r /var/cache/apt
mkdir -p $mnt/varcache/apt
ln -s $mnt/varcache/apt /var/cache/apt

#################################################################################
# 'skin shortcuts' addon
#apt update
#apt install -y bsdtar
#wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
#bsdtar -xf master.zip -C /home/osmc/.kodi/addons
#mv /home/osmc/.kodi/addons/script.skinshortcuts-master /home/osmc/.kodi/addons/script.skinshortcuts
#chown -R osmc:osmc /home/osmc/.kodi/addons/script.skinshortcuts
#rm master.zip

title2 "Install samba"
#################################################################################
apt install -y samba
# make usb drive a common between os for smb.conf
[[ ! -e $mnt/samba/smb.conf ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P $mnt/samba
rm /etc/samba/smb.conf
ln -s $mnt/samba/smb.conf /etc/samba/smb.conf
systemctl restart nmbd
systemctl restart smbd
# set samba password
smbpasswd -a root

# Transmission
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh 1

# Aria2
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh 1

# GPIO
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh 1
# make usb drive a common between os for gpio.json
[[ ! -e $mnt/gpio/gpio.json ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P $mnt/gpio
rm /home/osmc/gpio.json
ln -s $mnt/gpio/gpio.json /home/osmc/gpio.json
systemctl restart gpioset

title2 "System upgrade ..."
#################################################################################
apt upgrade

title "Finished."
