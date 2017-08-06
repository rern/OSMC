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
[[ ! -e /etc/profile.d/cmd.sh ]] && wget -qN --show-progress $gitpath/cmd.sh -P /etc/profile.d
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/motd/install.sh; chmod +x install.sh; ./install.sh
touch /root/.hushlogin

# passwords
echo -e "$bar root password for Samba and Transmission ...\n"
setpwd

if ! grep '^hdmi_mode=' /boot/config.txt &> /dev/null; then
echo -e "$bar Set HDMI mode ..."
#################################################################################
mmc 1
# force hdmi mode, remove black border (overscan)
hdmimode='
hdmi_group=1
hdmi_mode=31      # 1080p 50Hz
disable_overscan=1
hdmi_ignore_cec=1 # disable cec
'
! grep '^hdmi_mode=' /tmp/p1/config.txt &> /dev/null && echo "$hdmimode" >> /tmp/p1/config.txt
! grep '^hdmi_mode=' /boot/config.txt &> /dev/null && echo "$hdmimode" >> /boot/config.txt
fi
sed -i '/^gpio/ s/^/#/
' /tmp/p6/config.txt
echo

mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"
fstabmnt="/dev/sda1       $mnt         ext4  defaults,noatime"
if ! grep $mnt /etc/fstab &> /dev/null; then
  echo -e "$bar Mount USB drive to /mnt/hdd ..."
  #################################################################################
  echo "$fstabmnt" >> /etc/fstab
fi
echo

if [[ ! -L /var/cache/apt ]]; then
  echo -e "$bar Set apt cache ..."
  #################################################################################
	mkdir -p $mnt/varcache/apt
	rm -r /var/cache/apt
	ln -s $mnt/varcache/apt /var/cache/apt
fi
# disable setup marker files
touch /walkthrough_completed # initial setup
rm -f /vendor # noobs marker for update prompt
echo

echo -e "$bar Update package database ..."
#################################################################################
apt update

title "$bar Install bsdtar ..."
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
echo -e "$bar Update addons database ..."
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

echo -e "$bar Restore settings ..."
#################################################################################
wget -qN --show-progress $gitpath/advancedsettings.xml -P $kodipath                              # hide directory
wget -qN --show-progress $gitpath/guisettings.xml -P $kodipath                                   # all settings
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $kodipath/addon_data/script.skinshortcuts # hide home menu item
wget -qN --show-progress $gitpath/rpi_2708_1001_CEC_Adapter.xml -P $kodipath/peripheral_data     # disable cec adapter
chown -R osmc:osmc $kodipath
sed -i 's/id="check_freq" value="."/id="check_freq" value="0"/' $kodipath/addon_data/script.module.osmcsetting.updates/settings.xml
# extra command for some settings
echo 'Asia/Bangkok' > /etc/timezone
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Bangkok /etc/localtime
#hostname RT-AC66U

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
# ir remote keymap
sed -i -e 's|<homepage></homepage>|<homepage>RunScript(/home/osmc/gpioon.py)</homepage>|
' -e 's|<f4 mod="alt"></f4>|<f4 mod="alt">RunScript(/home/osmc/gpiooff.py)</f4>|
' /home/osmc/.kodi/userdata/keymaps/keyboard.xml
echo

#echo -e "$bar System upgrade ..."
#################################################################################
#apt -y upgrade

#systemctl daemon-reload # done in GPIO install
systemctl restart nmbd smbd mediacenter
echo -e "$bar OSMC restarted.\n"

# show installed packages status
echo -e "$bar Installed packages status"
systemctl | egrep 'aria2|nmbd|smbd|transmission'

timestop l
title -l = "$bar Setup finished successfully."
