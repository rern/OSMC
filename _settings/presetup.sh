#!/bin/bash

# stand alone usage: presetup.sh [partN]

# for source in: setup.sh, cmd.sh - resetosmc
# hdmi mode
# fstab usb mount
# apt cache

rm presetup.sh

echo -e "$bar Set HDMI mode ..."
#################################################################################
# force hdmi mode
if (( $# == 0 )); then
	mntroot=''
else
	mmc $1
	mntroot=/tmp/p$1
	mkdir -p $mntroot
	mount /dev/mmcblk0p$1
fi

file=label=$( e2label /dev/sda1 )
mnt=$mntroot/mnt/$label
mkdir -p $mntboot/config.txt
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
