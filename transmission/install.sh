#!/bin/bash

# install.sh [password] [webui] [startup]
#   [webui] = 1 / 0
#   [startup] = 1 / null )
#   any argument = no prompt + no package update

# import heading and password function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh
wget -qN https://github.com/rern/tips/raw/master/bash/f_password.sh; . f_password.sh; rm f_password.sh

rm install.sh

if type transmission-daemon &>/dev/null; then
	titleend "$info Transmission already installed."
	exit
fi
# user inputs
if (( $# == 0 )); then # with no argument
	title "$info Set password:"
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 anspwd
	[[ $anspwd == 1 ]] && setpwd

	title "$info Install WebUI alternative (Transmission Web Control):"
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 answebui

	title "$info Start Transmission on system startup:"
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 ansstartup
	echo
else # with arguments
	pwd1=$1
	(( $# > 1 )) && answebui=$2 || answebui=0
	(( $# > 2 )) && ansstartup=$3 || ansstartup=0
fi

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/uninstall_tran.sh
chmod +x uninstall_tran.sh

title2 "Install Transmission ..."
# skip with any argument
(( $# == 0 )) && apt update
apt install -y transmission-daemon transmission-cli

if [[ $answebui == 1 ]] && ! type bsdtar &>/dev/null; then
	title2 "Install bsdtar ..."
	apt install -y bsdtar
fi

if mount | grep '/dev/sda1' &>/dev/null; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	mkdir -p $mnt/transmission
	path=$mnt/transmission
else
	mkdir -p /root/transmission
	path=/root/transmission
fi
mkdir -p $path/{incomplete,watch}

# clear rc.d for systemd only
update-rc.d transmission-daemon remove

# custom systemd unit
systemctl stop transmission-daemon
systemctl disable transmission-daemon
#rm /etc/systemd/system/transmission*.service
cp /lib/systemd/system/transmission*.service /etc/systemd/system/transmission.service
sed -i -e 's|User=.*|User=root|
' -e '/ExecStart/ i\
Environment=TRANSMISSION_HOME='$path'\
Environment=TRANSMISSION_WEB_HOME='$path'/web
' /etc/systemd/system/transmission.service
systemctl daemon-reload

# create settings.json
file=$path/settings.json
[[ -e $file ]] && rm $file
systemctl start transmission; systemctl stop transmission

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
if [[ $anspwd == 1 ]] && [[ -n $pwd1 ]]; then
	sed -i -e 's|"rpc-authentication-required": false|"rpc-authentication-required": true|
	' -e 's|"rpc-password": ".*"|"rpc-password": "'"$pwd1"'"|
	' -e 's|"rpc-username": ".*"|"rpc-username": "root"|
	' $file
fi

# fix buffer warning on osmc
if ! grep 'net.core.rmem_max=4194304' /etc/sysctl.conf &> /dev/null; then
	echo -n 'net.core.rmem_max=4194304
	net.core.wmem_max=1048576
	' >> /etc/sysctl.conf
	sysctl -p
fi

# web ui alternative
if [[ $answebui == 1 ]]; then
	wget -qN --show-progress https://github.com/ronggang/transmission-web-control/raw/master/release/transmission-control-full.tar.gz
	mv /usr/share/transmission/web/index{,.original.}.html
	mv /usr/share/transmission/web $path
	rm /usr/share/transmission
	bsdtar -xf transmission-control-full.tar.gz -C $path
	rm transmission-control-full.tar.gz
	chown -R root:root $path/web
else
	rm -r /usr/share/transmission
fi

# start
[[ $ansstartup == 1 ]] && systemctl enable transmission
title "Start Transmission ..."
systemctl start transmission

title2 "Transmission installed and started successfully."
echo 'Uninstall: ./uninstall_tran.sh'
echo 'Start: sudo systemctl start transmission'
echo 'Stop: sudo systemctl stop transmission'
echo 'Download directory: '$path
echo 'WebUI: [OSMC_IP]:9091'
titleend "user: root"
