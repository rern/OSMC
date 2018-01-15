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

file=$mntroot/boot/config.txt
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

echo "/dev/sda1  $mnt  ext4  defaults,noatime" >> $mntroot/etc/fstab
echo

echo -e "$bar Disable SD card automount ..."
#################################################################################
rootnum=$( mount | grep 'on / ' | cut -d' ' -f1 | cut -d'p' -f2  )
bootnum=$(( rootnum - 1 ))

fstab=/etc/fstab

part1=/dev/mmcblk0p$bootnum
part2=/dev/mmcblk0p$rootnum
echo "$part1  /boot      vfat  defaults,noatime,noauto,x-systemd.automount    0   0
/dev/mmcblk0p1  /media/p1  vfat  noauto,noatime
/dev/mmcblk0p5  /media/p5  ext4  noauto,noatime
" >> $fstab
umount /dev/mmcblk0p1 2> /dev/null
umount /dev/mmcblk0p5 2> /dev/null

# omit current os from installed_os.json
partlist=$( fdisk -l /dev/mmcblk0 | grep mmcblk0p | awk -F' ' '{print $1}' | sed "/p1$\|p2$\|p5$\|$part1\|$part2/ d; sed s/\/dev\/mmcblk0p//" )
partarray=( $( echo $partlist ) )
ilength=${#partarray[*]}
mountlist=''
for (( i=0; i < ilength; i++ )); do
  (( $(( i % 2 )) == 0 )) && parttype=vfat || parttype=ext4
  p=${partarray[i]}
  mountlist+="/dev/mmcblk0p$p  /media/p$p  $parttype  noauto,noatime\n"
  umount /dev/mmcblk0p$p 2> /dev/null
done

echo "mountlist" >> $fstab

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
