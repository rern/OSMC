#!/bin/bash

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

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
titleend() {
	echo -e "\n$1"
	echo -e "\n$line\n"
}
setpwd() {
	echo
	echo 'Password: '
	read -s pwd1
	echo
	echo 'Retype password: '
	read -s pwd2
	echo
	if [[ $pwd1 != $pwd2 ]]; then
		echo
		echo "$info Passwords not matched. Try again."
		setpwd
	fi
}

rm setup.sh

# passwords
title "$info root password for Samba and Transmission ..."
setpwd

title2 "Set apt cache to usb drive ..."
#################################################################################
mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
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

title2 "Install Samba ..."
#################################################################################
apt install -y samba
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P /etc/samba
systemctl daemon-reload
systemctl restart nmbd smbd
# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

# Transmission
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh $pwd1 0 1

# Aria2
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh 1

# GPIO
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh 1
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P /home/osmc/gpio
systemctl restart gpioset

title2 "System upgrade ..."
#################################################################################
apt upgrade

title "Finished."
titleend "Please proceed to Settings > Interface > Enable customize home menu."
