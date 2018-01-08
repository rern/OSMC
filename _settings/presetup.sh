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
if (( $# == 0 )); then
	mntroot=''
else
	mmc $1
	mntroot=/tmp/p$1
	#sed -i '/gpio/ s/^/#/' $file
fi

if ! grep -q '^hdmi_mode=' $mntroot/boot/config.txt; then
sed -i '$ a\
hdmi_group=1\
hdmi_mode=31\
hdmi_ignore_cec=1	
' $mntroot/boot/config.txt
fi
echo

echo -e "$bar Mount USB drive to /mnt/hdd ..."
#################################################################################
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"

echo "/dev/sda1  $mnt  ext4  defaults,noatime" >> $mntroot/etc/fstab
echo

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
