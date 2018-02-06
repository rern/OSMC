#!/bin/bash

# stand alone usage: presetup.sh [partN]

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
label=$( e2label /dev/sda1 )
mnt=$mntroot/mnt/$label
mkdir -p $mnt

mountlist="/dev/sda1       $mnt   ext4  defaults,noatime
"
umount -l /dev/sda1
echo

echo -e "$bar Disable SD card automount ..."
#################################################################################
mntsettings=/tmp/SETTINGS
mkdir -p $mntsettings
mount /dev/mmcblk0p5 $mntsettings 2> /dev/null
installedlist=$( grep 'name\|mmc' $mntsettings/installed_os.json )
umount -l $mntsettings
rm -r $mntsettings

echo $installedlist | sed -n '/OSMC/N;N; p'
part1=$( echo "$installedlist" | sed -n '/OSMC/ {n; p}' )
part2=$( echo "$installedlist" | sed -n '/OSMC/ {n;n; p}' )
noautoarray=( $( echo "$installedlist" | sed '/OSMC/{N;N; d}; /name/ d; s/\/dev\/mmcblk0p//; s/[",]//g' ) )

mountlist+="$part1  /boot      vfat  defaults,noatime,noauto,x-systemd.automount    0   0
/dev/mmcblk0p1  /media/p1  vfat  noauto,noatime
/dev/mmcblk0p5  /media/p5  ext4  noauto,noatime
"
umount part1 2> /dev/null
umount -l /dev/mmcblk0p1 2> /dev/null
umount -l /dev/mmcblk0p5 2> /dev/null

ilength=${#noautoarray[*]}
for (( i=0; i < ilength; i++ )); do
  (( $(( i % 2 )) == 0 )) && parttype=vfat || parttype=ext4
  p=${noautoarray[i]}
  mountlist+="/dev/mmcblk0p$p  /media/p$p  $parttype  noauto,noatime\n"
  umount -l /dev/mmcblk0p$p 2> /dev/null
done

echo -e "$mountlist" > $mntroot/etc/fstab

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
