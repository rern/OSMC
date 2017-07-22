#!/bin/bash

# import heading and password function
wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
wget -qN https://github.com/rern/tips/raw/master/bash/f_password.sh; . f_password.sh; rm f_password.sh

rm setup.sh

# passwords
title "$info root password for Samba and Transmission ..."
setpwd

timestart=$( date +%s )

title "$bar Update package database ..."
#################################################################################
apt update

title "$bar Restore settings ..."
#################################################################################
gitpath=https://github.com/rern/OSMC/raw/master/_settings
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database

title "$bar Install bsdtar ..."
apt install -y bsdtar

title "$bar Install skin.shortcuts addons ..."
# 'skin shortcuts' addon
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
# force reload skin
#xbmc-send -a "UpdateLocalAddons()" # skin reload must refresh addons data after enable
#sleep 2
#xbmc-send -a "ReloadSkin()" # !!! reset guisettings.xml
#title "Skin reloaded"

# get backup settings
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts
chown -R osmc:osmc $kodipath

# reboot command
wget -qN --show-progress $gitpath/cmd.sh -P /etc/profile.d
# login banner
wget -qN --show-progress $gitpath/motd.banner -P /etc
rm /etc/motd

title -l = "$bar Install Samba ..."
#################################################################################
apt install -y samba
wget -q --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -O /etc/samba/smb.conf

# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

title -l = "$bar Samba installed successfully."

# Transmission
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh $pwd1 0 1

# Aria2
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh 1

# GPIO
#################################################################################
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P /home/osmc
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh 1

#title2 "System upgrade ..."
#################################################################################
#apt -y upgrade

#systemctl daemon-reload # done in GPIO install
systemctl restart nmbd smbd mediacenter
title "OSMC restarted."

# show installed packages status
title "Installed packages status"
systemctl | egrep 'aria2|nmbd|smbd|transmission'

timeend=$( date +%s )
timediff=$(( $timeend - $timestart ))
timemin=$(( $timediff / 60 ))
timesec=$(( $timediff % 60 ))

title -l = "$bar Setup finished successfully."
title -nt "Duration: $timemin min $timesec sec"
