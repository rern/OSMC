#!/bin/bash

# install.sh [password] [webui] [startup]
#   [webui] = 1 / 0
#   [startup] = 1 / null )
#   any argument = no prompt + no package update

rm $0

# import heading function
wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh
timestart

if type transmission-daemon &>/dev/null; then
	echo -e "$info Transmission already installed."
	exit
fi
# user inputs
if (( $# == 0 )); then # with no argument
	yesno "Set password:" anspwd
	[[ $anspwd == 1 ]] && setpwd

	yesno "Install WebUI alternative (Transmission Web Control):" answebui

	yesno "Start Transmission on system startup:" ansstartup
	echo
else # with arguments
	pwd1=$1
	(( $# > 1 )) && answebui=$2 || answebui=0
	(( $# > 2 )) && ansstartup=$3 || ansstartup=0
fi

wget -qN --show-progress https://raw.githubusercontent.com/rern/OSMC/master/transmission/uninstall_tran.sh
chmod +x uninstall_tran.sh

title -l = "$bar Install Transmission ..."
# skip with any argument
(( $# == 0 )) && apt update
apt install -y transmission-daemon transmission-cli

if [[ $answebui == 1 ]] && ! type bsdtar &>/dev/null; then
	echo -e "$bar Install bsdtar ..."
	apt install -y bsdtar
fi

if mount | grep -q '/dev/sda1'; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	mkdir -p $mnt/transmission
	path=$mnt/transmission
else
	mkdir -p /root/transmission
	path=/root/transmission
fi
mkdir -p $path/{incomplete,watch}

# custom systemd unit
systemctl stop transmission-daemon
systemctl disable transmission-daemon

ln -s /lib/systemd/system/trans{mission-daemon,}.service
dir=/etc/systemd/system/trans.service.d
mkdir $dir
echo '[Service]
User=root
Environment=TRANSMISSION_HOME=$path
Environment=TRANSMISSION_WEB_HOME=$path/web
' > $dir/override.conf
systemctl daemon-reload

# create settings.json
file=$path/settings.json
[[ -e $file ]] && rm $file
systemctl start trans; systemctl stop trans

sed -i -e 's|"download-dir": ".*"|"download-dir": "'"$path"'"|
' -e 's|"incomplete-dir": ".*"|"incomplete-dir": "'"$path"'/incomplete"|
' -e 's|"incomplete-dir-enabled": false|"incomplete-dir-enabled": true|
' -e 's|"rpc-whitelist-enabled": true|"rpc-whitelist-enabled": false|
' -e '/[^{},\{, \}]$/ s/$/, /
' -e '/}/ i\
    "watch-dir": "'"$path"'/watch", \
    "watch-dir-enabled": true
' $file

# set password
if [[ -n $pwd1 ]]; then
	sed -i -e 's|"rpc-authentication-required": false|"rpc-authentication-required": true|
	' -e 's|"rpc-password": ".*"|"rpc-password": "'"$pwd1"'"|
	' -e 's|"rpc-username": ".*"|"rpc-username": "root"|
	' $file
fi

# fix buffer warning on osmc
if ! grep -q 'net.core.rmem_max=4194304' /etc/sysctl.conf; then
	echo -n 'net.core.rmem_max=4194304
	net.core.wmem_max=1048576
	' >> /etc/sysctl.conf
	sysctl -p
fi

# web ui alternative
if [[ $answebui == 1 ]]; then
	wget -qN --show-progress https://raw.githubusercontent.com/ronggang/transmission-web-control/master/release/transmission-control-full.tar.gz
	cp /usr/share/transmission/web $path
	mv $path/web/index{,.original.}.html
	bsdtar -xf transmission-control-full.tar.gz -C $path
	rm transmission-control-full.tar.gz
	chown -R root:root $path/web
fi

# start
[[ $ansstartup == 1 ]] && systemctl enable trans
echo -e "$bar Start Transmission ..."
systemctl start trans

# clear rc.d for systemd only
update-rc.d transmission-daemon remove

timestop
title -l = "$bar Transmission installed and started successfully."
echo "Uninstall: ./uninstall_tran.sh"
echo "Run: sudo systemctl [ start / stop ] trans"
echo "Startup: sudo systemctl [ enable / disable ] trans"
echo
echo "Download directory: $path"
echo "Web UI: [OSMC_IP]:9091"
title -nt "User: root"
