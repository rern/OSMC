#!/bin/bash

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
bootpart=$( sed -n '/"OSMC"/{n;n; p}' $mntsettings/installed_os.json | sed 's/[",]//g' )
mntboot=${bootpart/dev\/mmcblk0/\tmp\/}

mkdir -p $mntboot
mount $bootpart $mntboot

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

# disable setup marker files
touch $mntroot/walkthrough_completed # initial setup
rm -f $mntroot/vendor # noobs marker for update prompt
