#!/bin/bash

rm $0

# import heading function
wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
timestart l

gitpath=https://github.com/rern/OSMC/raw/master/_settings
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database

# reboot command and motd
[[ -e /etc/profile.d/cmd.sh ]] && wget -qN --show-progress $gitpath/cmd.sh -P /etc/profile.d
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/motd/install.sh; chmod +x install.sh; ./install.sh
touch /root/.hushlogin

# passwords
title "root password for Samba and Transmission ..."
setpwd

title "$bar Update package database ..."
#################################################################################
apt update

title "Install bsdtar ..."
apt install -y bsdtar
echo

title "$bar Install skin.shortcuts addons ..."
#################################################################################
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
echo

title "$bar Restore settings ..."
#################################################################################
wget -qN --show-progress $gitpath/advancedsettings.xml -P $kodipath                              # hide directory
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath                                   # all settings
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts # hide home menu item
wget -qN --show-progress $gitpath/rpi_2708_1001_CEC_Adapter.xml -P $kodipath/peripheral_data     # disable cec adapter
chown -R osmc:osmc $kodipath

# reboot switch os
wget -qN --show-progress $gitpath/rebootosmcsudo.py -P /home/osmc
wget -qN --show-progress $gitpath/rebootrunesudo.py -P /home/osmc
chown osmc:osmc /home/osmc/*.py
chmod +x /home/osmc/*.py
# mod file
file=/usr/share/kodi/addons/skin.osmc/16x9/DialogButtonMenu.xml
linenum=$( sed -n '/Quit()/{=}' $file )
sed -i -e "$(( $linenum - 2 ))"' i\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>Reboot Rune</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/rebootrunesudo.py)</onclick>\
\t\t\t\t\t</item>\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>Reboot OSMC</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/rebootosmcsudo.py)</onclick>\
\t\t\t\t\t</item>
' $file
echo

title -l = "$bar Install Samba ..."
#################################################################################
timestart
apt install -y samba
wget -q --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -O /etc/samba/smb.conf

# set samba password
(echo $pwd1; echo $pwd1) | smbpasswd -s -a root

timestop
title -l = "$bar Samba installed successfully."
echo

# Transmission
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh $pwd1 0 1
echo

# Aria2
#################################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh 1
echo

# GPIO
#################################################################################
wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P /home/osmc
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh 1
echo

#title2 "System upgrade ..."
#################################################################################
#apt -y upgrade

#systemctl daemon-reload # done in GPIO install
systemctl restart nmbd smbd mediacenter
title "OSMC restarted."
echo

# show installed packages status
title "Installed packages status"
systemctl | egrep 'aria2|nmbd|smbd|transmission'
echo

timestop l
title -l = "$bar Setup finished successfully."
