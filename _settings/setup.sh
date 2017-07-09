#!/bin/bash

timestart=$( date +%s )

# import heading and password function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh
wget -qN https://github.com/rern/tips/raw/master/bash/f_password.sh; . f_password.sh; rm f_password.sh

rm setup.sh

titlebar "This setup will take 11 min."
echo

# passwords
titleinfo "root password for Samba and Transmission ..."
setpwd

titlebar "Update package database ..."
#################################################################################
apt update

titlebar "Restore settings ..."
#################################################################################
gitpath=https://github.com/rern/OSMC/raw/master/_settings
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database

titlebar "Install bsdtar ..."
apt install -y bsdtar

titlebar "Install skin.shortcuts addons ..."
# 'skin shortcuts' addon
title "Get addons and depends ..."
wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip -O $pkgpath/script.skinshortcuts.zip
wget -qN --show-progress https://github.com/XBMC-Addons/script.module.simplejson/archive/master.zip -O $pkgpath/script.module.simplejson.zip
wget -qN --show-progress http://mirrors.kodi.tv/addons/jarvis/script.module.unidecode/script.module.unidecode-0.4.16.zip -O $pkgpath/script.module.unidecode.zip
bsdtar -xf $pkgpath/script.skinshortcuts.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.simplejson.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.unidecode.zip -C $addonpath
chown -R osmc:osmc $addonpath
# add addons to database
title "Update addons database ..."
xbmc-send -a "UpdateLocalAddons()"
sleep 2
# enable addons in database
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.simplejson'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.unidecode'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.skinshortcuts'"
# refresh addons data after enable
xbmc-send -a "UpdateLocalAddons()"
#sleep 2
# force reload skin
#xbmc-send -a "ReloadSkin()"
#title "Skin reloaded"

# get backup settings
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts
chown -R osmc:osmc $kodipath

systemctl restart mediacenter
title "OSMC restarted."

title2 "Install Samba ..."
#################################################################################
apt install -y samba
wget -q --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -O /etc/samba/smb.conf
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
