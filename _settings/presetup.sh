#!/bin/bash

rm $0

mmc() {
	if [[ ! $( mount | grep p$1 ) ]]; then
		mkdir -p /tmp/p$1
		mount /dev/mmcblk0p$1 /tmp/p$1
	fi
}

if ! grep -q '^hdmi_mode=' /boot/config.txt; then
echo -e "$bar Set HDMI mode ..."
#################################################################################
mmc 1
if ! mount | grep -q 'mmcblk0p7'; then
  mmc 7
  mntroot=/tmp/p7
fi
# force hdmi mode, remove black border (overscan)
hdmimode='
hdmi_group=1
hdmi_mode=31      # 1080p 50Hz
disable_overscan=1
hdmi_ignore_cec=1 # disable cec
'
! grep -q '^hdmi_mode=' /tmp/p1/config.txt && echo "$hdmimode" >> /tmp/p1/config.txt
! grep -q '^hdmi_mode=' /tmp/p7/boot/config.txt && echo "$hdmimode" >> $mntroot/boot/config.txt
fi
sed -i '/gpio/ s/^/#/
' $mntroot/boot/config.txt
echo

echo -e "$bar Mount USB drive to /mnt/hdd ..."
#################################################################################
mnt0=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
label=${mnt0##/*/}
mnt="/mnt/$label"
mkdir -p "$mnt"
fstabmnt="/dev/sda1  $mnt  ext4  defaults,noatime"
if ! grep $mnt /etc/fstab &> /dev/null; then
  echo "$fstabmnt" >> $mntroot/etc/fstab
fi
echo

if [[ ! -L $mntroot/var/cache/apt ]]; then
  echo -e "$bar Set apt cache ..."
  #################################################################################
	mkdir -p $mnt/varcache/apt
	rm -r $mntroot/var/cache/apt
	ln -s $mnt/varcache/apt $mntroot/var/cache/apt
fi
# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
