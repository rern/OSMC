#!/bin/bash

rm install.sh

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )

title2() {
	echo -e "\n$line2\n"
	echo -e "$bar $1"
	echo -e "\n$line2\n"
}
title() {
	echo -e "\n$line"
	echo $1
	echo -e "$line\n"
}
titleend() {
	echo -e "\n$1"
	echo -e "\n$line\n"
}

if ! grep -qs '/media/hdd' /proc/mounts; then
	titleend "$info Hard drive not mount at /media/hdd"
	exit
fi

wget -q --show-progress https://github.com/rern/OSMC/raw/master/transmission/uninstall_tran.sh
chmod +x uninstall_tran.sh

if ! type transmission-daemon &>/dev/null; then
	title2 "Install Transmission ..."
	apt install -y transmission-daemon transmission-cli
else
	title "$info Transmission already installed."
	exit
fi

if [[ ! -e /media/hdd/transmission ]]; then
	mkdir /media/hdd/transmission
	mkdir /media/hdd/transmission/incomplete
	mkdir /media/hdd/transmission/torrents
	chown -R osmc:osmc /media/hdd/transmission
fi

# rename service
pgrep transmission &>/dev/null && systemctl stop transmission-daemon
systemctl disable transmission-daemon
# clear rc.d
update-rc.d transmission-daemon remove
cp /lib/systemd/system/transmission-daemon.service /etc/systemd/system/transmission.service
# change user to 'root'
sed -i 's|User=debian-transmission|User=root|' /etc/systemd/system/transmission.service
# refresh systemd services
systemctl daemon-reload
# create settings.json
systemctl start transmission
# stop to edit
systemctl stop transmission

file='/root/.config/transmission-daemon/settings.json'
sed -i -e 's|"download-dir": ".*"|"download-dir": "/media/hdd/transmission"|
' -e 's|"incomplete-dir": ".*"|"incomplete-dir": "/media/hdd/transmission/incomplete"|
' -e 's|"incomplete-dir-enabled": false|"incomplete-dir-enabled": true|
' -e 's|"rpc-whitelist-enabled": true|"rpc-whitelist-enabled": false|
' -e '/[^{},\{, \}]$/ s/$/, /
' -e '/}/ i\
    "watch-dir": "/media/hdd/transmission/torrents", \
    "watch-dir-enabled": true
' $file

title "$info Set password:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo
		echo 'Username: '
		read usr 
		echo 'Password: '
		read -s pwd
		sed -i -e 's|"rpc-authentication-required": false|"rpc-authentication-required": true|
		' -e "s|\"rpc-password\": \".*\"|\"rpc-password\": \"$pwd\"|
		" -e "s|\"rpc-username\": \".*\"|\"rpc-username\": \"$usr\"|
		" $file
		;;
	* ) echo;;
esac
# set buffer
echo 'net.core.rmem_max=4194304
net.core.wmem_max=1048576
' >> /etc/sysctl.conf
sysctl -p

title "$info Start Transmission on system startup:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl enable transmission;;
	* ) echo;;
esac

title "$info Start Transmission now:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl start transmission;;
	* ) echo;;
esac

title2 "Transmission installed successfully."
echo 'Uninstall: ./uninstall_tran.sh'
echo 'Start: sudo systemctl start transmission'
echo 'Stop: sudo systemctl stop transmission'
echo 'Download directory: /media/hdd/transmission'
titleend "WebUI: [OSMC_IP]:9091"
