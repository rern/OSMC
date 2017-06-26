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

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/uninstall_tran.sh
chmod +x uninstall_tran.sh

if ! type transmission-daemon &>/dev/null; then
	title2 "Install Transmission ..."
	apt update
	apt install -y transmission-daemon transmission-cli
else
	title "$info Transmission already installed."
	exit
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

# rename service
pgrep transmission &>/dev/null && systemctl stop transmission-daemon
systemctl disable transmission-daemon
# clear rc.d
update-rc.d transmission-daemon remove
cp /lib/systemd/system/transmission-daemon.service /etc/systemd/system/transmission.service
# change user to 'root'
sed -i -e '/^After=/ s/$/ nmbd.service smbd.service/
' -e 's/User=debian-transmission/User=root/
' -e 's/Type=notify/Type=idle/
' -e '/transmission-daemon -f --log-error$/ s|$| --config-dir '"$path"'|
' /etc/systemd/system/transmission.service
# refresh systemd services
systemctl daemon-reload
# create settings.json
systemctl start transmission; systemctl stop transmission

file=$path/settings.json
sed -i -e 's|"download-dir": ".*"|"download-dir": "'"$path"'"|
' -e 's|"incomplete-dir": ".*"|"incomplete-dir": "'"$path"'/incomplete"|
' -e 's|"incomplete-dir-enabled": false|"incomplete-dir-enabled": true|
' -e 's|"rpc-whitelist-enabled": true|"rpc-whitelist-enabled": false|
' -e '/[^{},\{, \}]$/ s/$/, /
' -e '/}/ i\
    "watch-dir": "'"$path"'/watch", \
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
		echo 'Password: '
		read -s pwd
		sed -i -e 's|"rpc-authentication-required": false|"rpc-authentication-required": true|
		' -e 's|"rpc-password": ".*"|"rpc-password": "'"$pwd"'"|
		' -e 's|"rpc-username": ".*"|"rpc-username": "root"|
		' $file
		;;
	* ) echo;;
esac
# hash password by start
systemctl start transmission

# web ui alternative
title "$info Install WebUI alternative (Transmission Web Control):"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo
		wget -qN --show-progress https://github.com/ronggang/transmission-web-control/raw/master/release/transmission-control-full.tar.gz
		mv /usr/share/transmission/web/index.html /usr/share/transmission/web/index.original.html
		bsdtar -xf transmission-control-full.tar.gz -C /usr/share/transmission
		rm transmission-control-full.tar.gz
		chown -R root:root /usr/share/transmission/web
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
	1 ) echo;;
	* ) systemctl stop transmission;;
esac

title2 "Transmission installed successfully."
echo 'Uninstall: ./uninstall_tran.sh'
echo 'Start: sudo systemctl start transmission'
echo 'Stop: sudo systemctl stop transmission'
echo 'Download directory: '$path
echo 'WebUI: [OSMC_IP]:9091'
titleend "user: root"
