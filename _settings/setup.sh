#!/bin/bash

### force hdmi mode ################################################################
echo '
hdmi_group=1
hdmi_mode=31
' >> /boot/config.txt

### set fstab for usb drive ########################################################
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt=/mnt/$label
mkdir -p $mnt
echo "/dev/sda1       $mnt           ext4     defaults,noatime  0   0" >> /etc/fstab
umount -l $mnt0
mount -a

### set apt cache to usb drive ####################################################
rm -r /var/cache/apt
mkdir -p $mnt/varcache/apt
ln -s $mnt/varcache/apt /var/cache/apt

### Settings ######################################################################
# 'skin shortcuts' addon
#apt update
#apt install -y bsdtar
#wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
#bsdtar -xf master.zip -C /home/osmc/.kodi/addons
#mv /home/osmc/.kodi/addons/script.skinshortcuts-master /home/osmc/.kodi/addons/script.skinshortcuts
#chown -R osmc:osmc /home/osmc/.kodi/addons/script.skinshortcuts
#rm master.zip

# customized file
gitpath=https://github.com/rern/OSMC/raw/master/_settings
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P /home/osmc/.kodi/userdata/addon_data/script.skinshortcuts
wget -qN --show-progress $gitpath/guisettings.xml -P /home/osmc/.kodi/userdata
# setup marker file
touch /walkthrough_completed
systemctl restart mediacenter

### samba ##########################################################################
apt install -y samba
# make usb drive a common between os for smb.conf
[[ ! -e $mnt/samba/smb.conf ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/smb.conf -P $mnt/samba
rm /etc/samba/smb.conf
ln -s $mnt/samba/smb.conf /etc/samba/smb.conf
systemctl restart nmbd
systemctl restart smbd
# set samba password
smbpasswd -a root

### Transmission ####################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh 1

### Aria2 ###########################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh 1

### GPIO ############################################################################
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh 1
# make usb drive a common between os for gpio.json
[[ ! -e $mnt/gpio/gpio.json ]] && wget -qN --show-progress https://github.com/rern/RuneAudio/raw/master/_settings/gpio.json -P $mnt/gpio
rm /home/osmc/gpio.json
ln -s $mnt/gpio/gpio.json /home/osmc/gpio.json
systemctl restart gpioset
