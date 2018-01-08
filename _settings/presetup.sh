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
	file=/boot/config.txt
else
	mmc $1
	file=/tmp/p$1/boot/config.txt
	#sed -i '/gpio/ s/^/#/' $file
fi

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
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"
if (( $# == 0 )); then
	file=/etc/fstab
else
	mmc $1
	file=/tmp/p$1/etc/fstab
fi
echo "/dev/sda1  $mnt  ext4  defaults,noatime" >> $file
echo

echo -e "$bar Set apt cache ..."
#################################################################################
mkdir -p $mnt/varcache/apt
rm -rf $mntroot/var/cache/apt
ln -sf $mnt/varcache/apt $mntroot/var/cache/apt

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
