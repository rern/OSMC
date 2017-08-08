#!/bin/bash

# hdmi mode
# fstab usb mount
# apt cache

rm $0

mmc() {
	[[ -z $2 ]] && mntdir=/tmp/p$1 || mntdir=/tmp/$2
	if [[ ! $( mount | grep $mntdir ) ]]; then
		mkdir -p $mntdir
		mount /dev/mmcblk0p$1 $mntdir
	fi
}

echo -e "$bar Set HDMI mode ..."
#################################################################################
# force hdmi mode, remove black border (overscan)
hdmimode='
hdmi_group=1
hdmi_mode=31      # 1080p 50Hz
disable_overscan=1
hdmi_ignore_cec=1' # disable cec

mmc 6
! grep -q '^hdmi_mode=' /tmp/p6/boot/config.txt && echo "$hdmimode" >> /tmp/p6/boot/config.txt
sed -i '/gpio/ s/^/#/' /tmp/p6/boot/config.txt
echo

echo -e "$bar Mount USB drive to /mnt/hdd ..."
#################################################################################
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"
mmc 7
mntroot=/tmp/p7
echo "/dev/sda1  $mnt  ext4  defaults,noatime" >> $mntroot/etc/fstab
echo

echo -e "$bar Set apt cache ..."
#################################################################################
if [[ ! -L $mntroot/var/cache/apt ]]; then
	mkdir -p $mnt/varcache/apt
	rm -r $mntroot/var/cache/apt
	ln -s $mnt/varcache/apt $mntroot/var/cache/apt
fi
# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
