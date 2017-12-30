#!/bin/bash

# command shortcuts and motd
# passwords for samba and transmission
# hdmi mode, fstab, apt cache
# 'skin shortcuts' addon
# restore settings
# install samba
# install transmission
# install aria2
# install osmc gpio

rm $0

# import heading function
wget -qN --show-progress https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
timestart l

gitpath=https://github.com/rern/OSMC/raw/master
gitpathrune=https://github.com/rern/RuneAudio/raw/master
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database

# command shortcuts and motd
[[ ! -e /etc/profile.d/cmd.sh ]] && wgetnc $gitpath/_settings/cmd.sh -P /etc/profile.d
wgetnc $gitpath/motd/install.sh; chmod +x install.sh; ./install.sh
touch /root/.hushlogin

# passwords for samba and transmission
echo -e "$bar root password for Samba and Transmission ..."
setpwd

# hdmi mode, fstab, apt cache
if [[ ! -e /walkthrough_completed ]]; then
    wgetnc $gitpath/_settings/presetup.sh
    . presetup.sh
    echo
fi

echo -e "$bar Update package database ..."
#################################################################################
apt update

title "$bar Install bsdtar ..."
apt install -y bsdtar
echo

title "$bar Install skin.shortcuts addons ..."
#################################################################################
wgetnc https://github.com/BigNoid/script.skinshortcuts/archive/master.zip -O $pkgpath/script.skinshortcuts.zip
wgetnc https://github.com/XBMC-Addons/script.module.simplejson/archive/master.zip -O $pkgpath/script.module.simplejson.zip
wgetnc http://mirrors.kodi.tv/addons/jarvis/script.module.unidecode/script.module.unidecode-0.4.16.zip -O $pkgpath/script.module.unidecode.zip
bsdtar -xf $pkgpath/script.skinshortcuts.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.simplejson.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.unidecode.zip -C $addonpath
chown -R osmc:osmc $addonpath
# add addons to database
echo -e "$bar Update addons database ..."
xbmc-send -a "UpdateLocalAddons()"
sleep 5

# enable addons in database
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.simplejson'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.unidecode'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.skinshortcuts'"
# force reload skin
#xbmc-send -a "UpdateLocalAddons()" # skin reload must refresh addons data after enable
#sleep 2
#xbmc-send -a "ReloadSkin()" # !!! reset guisettings.xml
#title "Skin reloaded"
echo

echo -e "$bar Restore settings ..."
#################################################################################
wgetnc $gitpath/_settings/advancedsettings.xml -P $kodipath                              # hide directory
wgetnc $gitpath/_settings/guisettings.xml -P $kodipath                                   # all settings
wgetnc $gitpath/_settings/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts # hide home menu item
wgetnc $gitpath/_settings/rpi_2708_1001_CEC_Adapter.xml -P $kodipath/peripheral_data     # disable cec adapter
wgetnc $gitpath/_settings/settings.xml -P $kodipath/addon_data/script.module.osmcsetting.updates # websocket
chown -R osmc:osmc $kodipath

# extra command for some settings
echo 'Asia/Bangkok' > /etc/timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
#hostname RT-AC66U
sed -i 's/info,man/info,locale,man/' /usr/local/bin/runereset

title -l = "$bar Install Samba ..."
#################################################################################
timestart
apt install -y samba
wgetnc $gitpathrune/_settings/smb.conf -O /etc/samba/smb.conf

# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

timestop
title -l = "$bar Samba installed successfully."
echo

# Transmission
#################################################################################
wgetnc $gitpath/transmission/install.sh; chmod +x install.sh; ./install.sh $pwd1 0 1
echo

# Aria2
#################################################################################
wgetnc $gitpath/aria2/install.sh; chmod +x install.sh; ./install.sh 1
echo

# GPIO
#################################################################################
wgetnc $gitpathrune/_settings/gpio.json -P /home/osmc
wgetnc https://github.com/rern/OSMC_GPIO/raw/master/install.sh; chmod +x install.sh; ./install.sh 1
# ir remote keymap
sed -i -e 's|<homepage></homepage>|<homepage>RunScript(/home/osmc/gpioon.py)</homepage>|
' -e 's|<f4 mod="alt"></f4>|<f4 mod="alt">RunScript(/home/osmc/gpiooff.py)</f4>|
' /home/osmc/.kodi/userdata/keymaps/keyboard.xml
echo

#systemctl daemon-reload # done in GPIO install
systemctl restart nmbd smbd mediacenter
echo -e "$bar OSMC restarted.\n"

# show installed packages status
title "$bar Installed packages status"
systemctl | egrep 'aria2|nmbd|smbd|transmission'

timestop l
title -l = "$bar Setup finished successfully."
