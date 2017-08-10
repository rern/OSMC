#!/bin/bash

# install.sh [startup]
#   [startup] = 1 / null
#   any argument = no prompt + no package update

rm $0

# import heading function
wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh
timestart

if type aria2c &>/dev/null; then
	echo -e "$info Aria2 already installed."
	exit
fi

if (( $# == 0 )); then
	yesno "$info Start Aria2 on system startup:" ansstartup
else
	ansstartup=1
fi

wget -qN --show-progress https://raw.githubusercontent.com/rern/OSMC/master/aria2/uninstall_aria.sh
chmod +x uninstall_aria.sh

title -l = "$bar Install Aria2 ..."
# skip with any argument
if (( $# == 0 )); then
	echo -e "$bar Update package databases..."
	apt update
fi

apt install -y aria2
if ! type bsdtar &>/dev/null; then
	echo -e "$bar Install bsdtar ..."
	apt install -y bsdtar
fi

if mount | grep -q '/dev/sda1'; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	mkdir -p $mnt/aria2
	path=$mnt/aria2
else
	mkdir -p /root/aria2
	path=/root/aria2
fi
if (( $# == 0 )); then
	echo -e "$bar Get WebUI files ..."
	wget -qN --show-progress https://github.com/ziahamza/webui-aria2/archive/master.zip
	mkdir -p $path/web
	bsdtar -xf master.zip -s'|[^/]*/||' -C $path/web
	rm master.zip
fi
# link to kodi web root
ln -s $path/web /usr/share/kodi/addons/webinterface.default/aria2
# change webui port to 80
sed -i 's/8080/80/g' /home/osmc/.kodi/userdata/guisettings.xml
systemctl restart mediacenter

mkdir -p /root/.aria2
echo "enable-rpc=true
rpc-listen-all=true
daemon=true
disable-ipv6=true
dir=$path
max-connection-per-server=4
" > /root/.aria2/aria2.conf

echo '[Unit]
Description=Aria2
After=network-online.target
[Service]
Type=forking
ExecStart=/usr/bin/aria2c
[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/aria2.service

# start
[[ $ansstartup == 1 ]] && systemctl enable aria2
echo -e "$bar Start Aria2 ..."
systemctl start aria2

timestop
title -l = "$bar Aria2 installed and started successfully."
echo "Uninstall: ./uninstall_aria.sh"
echo
echo "Run: sudo systemctl [ start /stop ] aria2"
echo "Startup: sudo systemctl [ enable /disable ] aria2"
echo
echo "Download directory: $path"
echo -e "$info OSMC web interface changed to port:80"
title -nt "WebUI: [OSMC_IP]/aria2/"
