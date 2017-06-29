#!/bin/bash

### apt cache
rm -r /var/cache/apt
mkdir -p /media/hdd/varcache/apt
ln -s /media/hdd/varcache/apt /var/cache/apt

### disable cec
echo 'hdmi_ignore_cec=1' >> /boot/config.txt

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
# customized file
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/smb.conf -P /etc/samba
systemctl restart nmbd
systemctl restart smbd

smbpasswd -a root

### Aria2
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh


### Transmission
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh

systemctl stop transmission

pathhdd=/media/hdd/transmission
mkdir -p $pathhdd/blocklists
mkdir -p $pathhdd/resume
mkdir -p $pathhdd/torrents

if [[ -e $pathhdd/web ]]; then
  rm -r /usr/share/transmission/web
else
  mv /usr/share/transmission/web $pathhdd/web
fi
ln -s $pathhdd/web /usr/share/transmission/web

path=/var/lib/transmission-daemon/.config/transmission-daemon
[[ ! -e $pathhdd/settings.json ]] && mv $path/settings.json $pathhdd
rm -r $path/*
ln -s $pathhdd/blocklists $path/blocklists
ln -s $pathhdd/resume $path/resume
ln -s $pathhdd/torrents $path/torrents
ln -s $pathhdd/settings.json $path/settings.json

### GPIO
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
# customized file
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/gpio.json -P /home/osmc
