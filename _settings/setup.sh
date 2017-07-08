#!/bin/bash

timestart=$( date +%s )

# import heading and password function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh
wget -qN https://github.com/rern/tips/raw/master/bash/f_password.sh; . f_password.sh; rm f_password.sh

rm setup.sh

title "This setup will take 11 min."
echo

# passwords
titleinfo "root password for Samba and Transmission ..."
setpwd

title "Update package database ..."
#################################################################################
apt update

title "Restore settings ..."
#################################################################################
gitpath=https://github.com/rern/OSMC/raw/master/_settings
kodipath=/home/osmc/.kodi/userdata

# get backup settings
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts
chown -R osmc:osmc $kodipath

# 'skin shortcuts' addon
addonpath=/home/osmc/.kodi/addons
apt install -y bsdtar
# get addons and depends
#wget -qN --show-progress $gitpath/addons.zip
#bsdtar -xf addons.zip -C $addonpath/packages
#rm addons.zip
wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip -O $addonpath/packages/script.skinshortcuts.zip
wget -qN --show-progress https://github.com/XBMC-Addons/script.module.simplejson/archive/master.zip -O $addonpath/packages/script.module.simplejson.zip
wget -qN --show-progress http://mirrors.kodi.tv/addons/jarvis/script.module.unidecode/script.module.unidecode-0.4.16.zip -O $addonpath/packages/script.module.unidecode.zip
bsdtar -xf $addonpath/packages/script.skinshortcuts.zip -C $addonpath
bsdtar -xf $addonpath/packages/script.module.simplejson.zip -C $addonpath
bsdtar -xf $addonpath/packages/script.module.unidecode.zip -C $addonpath
chown -R osmc:osmc $addonpath
# enable addons in database
dbpath=$kodipath/Database
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.simplejson'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.unidecode'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.skinshortcuts'"
# update addons status
xbmc-send -a "UpdateAddonRepos()"
xbmc-send -a "UpdateLocalAddons()"
xbmc-send -a "ReloadSkin()"
#systemctl restart mediacenter

title2 "Install Samba ..."
#################################################################################
apt install -y samba
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P /etc/samba
systemctl daemon-reload
systemctl restart nmbd smbd
# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

title2 "Samba installed successfully." 

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
titleend "Duration: $timemin min $timesec sec"
