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

wget -q --show-progress -O uninstall_tran.sh "https://github.com/rern/RuneAudio/blob/master/transmission/uninstall_tran.sh?raw=1"
chmod +x uninstall_tran.sh

if ! type transmission-daemon > /dev/null 2>&1; then
	title2 "Install Transmission ..."
	apt install -y transmission-daemon transmission-cli
else
	title "$info Transmission already installed."
	exit
fi

# settings at /root/.config
systemctl stop transmission-daemon
pkill transmission-daemon
sed -i 's|User=debian-transmission|User=root|' /lib/systemd/system/transmission-daemon.service
systemctl daemon-reload
mkdir -p /root/.config/transmission-daemon
cp /var/lib/transmission-daemon/.config/transmission-daemon/settings.json /root/.config/transmission-daemon/

if [[ ! -e /media/hdd/transmission ]]; then
	mkdir /media/hdd/transmission
	mkdir /media/hdd/transmission/incomplete
	mkdir /media/hdd/transmission/torrents
	chown -R osmc:osmc /media/hdd/transmission
fi

file='/root/.config/transmission-daemon/settings.json'
sed -i -e 's|"download-dir": ".*"|"download-dir": "/media/hdd/transmission"|
' -e 's|"incomplete-dir": ".*"|"incomplete-dir": "/media/hdd/transmission/incomplete"|
' -e 's|"incomplete-dir-enabled": false|"incomplete-dir-enabled": true|
' -e 's|"rpc-whitelist": "127.0.0.1"|"rpc-whitelist": "*.*.*.*"|
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

title "$info Enable Transmission on system startup:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) systemctl disable transmission-daemon;;
esac

title "$info Start Transmission now:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) systemctl start transmission-daemon;;
esac

title2 "Transmission installed successfully."
echo 'Uninstall: ./uninstall_tran.sh'
echo 'Start: sudo systemctl start transmission-daemon'
echo 'Stop: sudo systemctl stop transmission-daemon'
echo 'Download directory: /media/hdd/transmission'
titleend "WebUI: [OSMC_IP]:9091"
