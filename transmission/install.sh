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

wget -q --show-progress -O tranuninstall.sh "https://github.com/rern/RuneAudio/blob/master/transmission/tranuninstall.sh?raw=1"; chmod +x tranuninstall.sh

file='/etc/transmission-daemon/settings.json'

if ! dpkg -s transmission-daemon > /dev/null 2>&1; then
	title "$bar Install Transmission ..."
	apt install -y transmission-daemon transmission-cli
else
	title "$info Transmission already installed."
	exit
fi
systemctl stop transmission

if [[ ! -e /media/hdd/transmission ]]; then
	mkdir /media/hdd/transmission
	mkdir /media/hdd/transmission/incomplete
	mkdir /media/hdd/transmission/torrents
	chown -R osmc:osmc /media/hdd/transmission
fi

sed -i -e 's|\"download-dir\": \".*\",|\"download-dir\": \"/media/hdd/transmission\",|
' -e 's|\"incomplete-dir\": \".*\",|\"incomplete-dir\": \"/media/hdd/transmission/incomplete\",|
' -e 's|\"incomplete-dir-enabled\": false,|\"incomplete-dir-enabled\": true,|
' -e 's|\"rpc-whitelist\": \"127.0.0.1\",|\"rpc-whitelist\": \"*.*.*.*\",|
' -e '/[^{},]$/ s/$/\,/
' -e '/}/ i\
    \"watch-dir\": \"/media/hdd/transmission/torrents\",\
    \"watch-dir-enabled\": true
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
			sed -i -e 's|\"rpc-authentication-required\": false,|\"rpc-authentication-required\": true,|
			' -e "s|\"rpc-password\": \".*\",|\"rpc-password\": \"$pwd\",|
			" -e "s|\"rpc-username\": \".*\",|\"rpc-username\": \"$usr\",|
			" $file
		;;
	* ) echo;;
esac

title "$info Enable transmission on system startup:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) systemctl disable transmission;;
esac

title "$bar Transmission installed successfully."
echo 'Download directory: /media/hdd/transmission'
echo 'Start: systemctl start transmission-daemon'
echo 'Stop: systemctl stop transmission-daemon'
titleend "Web Interface: [IP address]:9091"
