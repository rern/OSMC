#!/bin/bash

# for source in: setup.sh, cmd.sh - resetosmc
# hdmi mode
# fstab usb mount
# apt cache

rm presetup.sh

mmc() {
	[[ $2 ]] && mntdir=/tmp/$2 || mntdir=/tmp/p$1
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
	fi
}

echo -e "$bar Set HDMI mode ..."
#################################################################################
# force hdmi mode
hdmimode='
hdmi_group=1
hdmi_mode=31 
hdmi_ignore_cec=1'

if (( $# == 0 )); then
	file=/boot/config.txt
else
	file=/tmp/p$1/config.txt
	mmc $1
	#sed -i '/gpio/ s/^/#/' /tmp/p6/config.txt
fi
! grep -q '^hdmi_mode=' $file && echo "$hdmimode" >> $file
echo

echo -e "$bar Mount USB drive to /mnt/hdd ..."
#################################################################################
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"
mmc 9
mntroot=/tmp/p9
echo "/dev/sda1  $mnt  ext4  defaults,noatime" >> $mntroot/etc/fstab
echo

echo -e "$bar Set apt cache ..."
#################################################################################
mkdir -p $mnt/varcache/apt
rm -rf $mntroot/var/cache/apt
ln -sf $mnt/varcache/apt $mntroot/var/cache/apt

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
