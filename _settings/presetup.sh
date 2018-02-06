#!/bin/bash

# stand alone usage: presetup.sh [partN]

# for source in: setup.sh, cmd.sh - resetosmc
# hdmi mode
# fstab usb mount
# apt cache

rm presetup.sh

echo -e "$bar Set HDMI mode ..."
#################################################################################
mntsettings=/tmp/SETTINGS
mkdir -p $mntsettings
mount /dev/mmcblk0p5 $mntsettings 2> /dev/null
installedlist=$( grep 'name\|mmc' $mntsettings/installed_os.json | sed 's/[",]//g; s/\/dev\/mmcblk0p//' )
bootnum=$( echo "$installedlist" | sed -n '/OSMC/{n; p}' )
rootnum=$( echo "$installedlist" | sed -n '/OSMC/{n;n; p}' )

mntboot=/tmp/p$bootnum
mntroot=/tmp/p$rootnum
mkdir -p $mntboot
mkdir -p $mntroot
mount /dev/mmcblk0p$bootnum $mntboot
mount /dev/mmcblk0p$rootnum $mntroot

# force hdmi mode
file=$mntboot/config.txt
if ! grep -q '^hdmi_mode=' $file; then
sed -i '$ a\
hdmi_group=1\
hdmi_mode=31\
hdmi_ignore_cec=1	
' $file
fi
echo

echo -e "$bar Mount USB drive to /mnt/hdd ..."
#################################################################################
label=$( e2label /dev/sda1 )
mnt=$mntroot/mnt/$label
mkdir -p $mnt

sed "1 i\/dev/sda1       /mnt/$label   ext4  defaults,noatime" $mntroot/etc/fstab
umount -l /dev/sda1
mount -a
echo

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
