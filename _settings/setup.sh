#!/bin/bash

timestart=$( date +%s )

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

# 'skin shortcuts' addon
#addonpath=/home/osmc/.kodi/addons
#apt install -y bsdtar
#wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
#bsdtar -xf master.zip -C $addonpath
#mv $addonpath/script.skinshortcuts{-master,}
#chown -R osmc:osmc $addonpath/script.skinshortcuts
#rm master.zip
#xbmc-send -a "UpdateLocalAddons"

wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts
chown -R osmc:osmc $kodipath
# setup marker file
touch /walkthrough_completed
systemctl restart mediacenter

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
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P /home/osmc
systemctl restart gpioset

#title2 "System upgrade ..."
#################################################################################
#apt -y upgrade
#systemctl restart mediacenter

timeend=$( date +%s )
timediff=$(( $timeend - $timestart ))
timemin=$(( $timediff / 60 ))
timesec=$(( $timediff % 60 ))

title2 "Setup finished successfully."
echo "Duration: $timemin min $timesec sec"
titleend "Proceed to Settings > Interface > Configure skin > Enable menu customization."
