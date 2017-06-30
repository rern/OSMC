#!/bin/bash

mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt##/*/}

### apt cache
rm -r /var/cache/apt
mkdir -p $mnt/varcache/apt
ln -s $mnt/varcache/apt /var/cache/apt

### disable cec
#echo 'hdmi_ignore_cec=1' >> /boot/config.txt

### Settings
# 'skin shortcuts' addon
apt update
apt install -y bsdtar
wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
bsdtar -xf master.zip -C /home/osmc/.kodi/addons
mv /home/osmc/.kodi/addons/script.skinshortcuts-master /home/osmc/.kodi/addons/script.skinshortcuts
chown -R osmc:osmc /home/osmc/.kodi/addons/script.skinshortcuts
rm master.zip

# customized file
gitpath=https://github.com/rern/OSMC/raw/master/_settings
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P /home/osmc/.kodi/userdata/addon_data/script.skinshortcuts
wget -qN --show-progress $gitpath/guisettings.xml -P /home/osmc/.kodi/userdata

touch /walkthrough_completed
systemctl restart mediacenter

### samba
apt install samba

# make usb drive a common between os for smb.conf
[[ ! -e /media/hdd/samba/smb.conf ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P /media/hdd/samba
rm /etc/samba/smb.conf
ln -s /media/hdd/samba/smb.conf /etc/samba/smb.conf

systemctl restart nmbd
systemctl restart smbd

smbpasswd -a root

### Aria2
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh


### Transmission
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh

systemctl stop transmission

# make usb drive a common between os for web, settings.json, directory
pathhdd=$mnt/transmission
if [[ -e $pathhdd/web ]]; then
  rm -r /usr/share/transmission/web
else
  mv /usr/share/transmission/web $pathhdd/web
fi
ln -s $pathhdd/web /usr/share/transmission/web

path=/root/.config/transmission-daemon
if [[ ! -e $pathhdd/settings.json ]]; then
  mkdir -p $pathhdd/blocklists
  mkdir -p $pathhdd/resume
  mkdir -p $pathhdd/torrents
  mv $path/settings.json $pathhdd
fi
rm -r $path
ln -s $pathhdd $path

### GPIO
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
# make usb drive a common between os for gpio.json
[[ ! -e /media/hdd/gpio/gpio.json ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P /media/hdd/gpio
ln -s /media/hdd/gpio/gpio.json /home/osmc/gpio.json
