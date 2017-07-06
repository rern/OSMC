#!/bin/bash

# import heading and password function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh
wget -qN https://github.com/rern/tips/raw/master/bash/f_password.sh; . f_password.sh; rm f_password.sh

rm setup.sh

# passwords
title "$info root password for Samba and Transmission ..."
setpwd

title "Restore settings ..."
#################################################################################
gitpath=https://github.com/rern/OSMC/raw/master/_settings
kodipath=/home/osmc/.kodi/userdata
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts
chown -R osmc:osmc $kodipath
# setup marker file
touch /walkthrough_completed
systemctl restart mediacenter

# 'skin shortcuts' addon
#apt install -y bsdtar
#wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
#bsdtar -xf master.zip -C /home/osmc/.kodi/addons
#mv /home/osmc/.kodi/addons/script.skinshortcuts-master /home/osmc/.kodi/addons/script.skinshortcuts
#chown -R osmc:osmc /home/osmc/.kodi/addons/script.skinshortcuts
#rm master.zip

title "Update package list ..."
#################################################################################
apt update

title2 "Install Samba ..."
#################################################################################
apt install -y samba
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P /etc/samba
systemctl daemon-reload
systemctl restart nmbd smbd
# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

title "Samba installed successfully." 

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

#title2 "System upgrade ..."
#################################################################################
#apt -y upgrade
#systemctl restart mediacenter

title2 "Setup finished successfully."
titleend "Proceed to Settings > Interface > Configure skin > Enable menu customization."
