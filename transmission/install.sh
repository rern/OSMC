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
setpwd() {
	echo
	echo 'Password: '
	read -s pwd1
	echo
	echo 'Retype password: '
	read -s pwd2
	echo
	if [[ $pwd != $pwd2 ]]; then
		echo
		echo "$info Passwords not matched. Try again."
		setpwd
	fi
}

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/uninstall_tran.sh
chmod +x uninstall_tran.sh

if ! type transmission-daemon &>/dev/null; then
	title2 "Install Transmission ..."
	# skip with any argument
	(( $# == 0 )) && apt update
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

title "$info Set password:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo
		echo 'Password: '
		setpwd
		sed -i -e 's|"rpc-authentication-required": false|"rpc-authentication-required": true|
		' -e 's|"rpc-password": ".*"|"rpc-password": "'"$pwd1"'"|
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
		mv /usr/share/transmission/web $path
		mv $path/web/index.html $path/web/index.original.html
		bsdtar -xf transmission-control-full.tar.gz -C $path
		rm transmission-control-full.tar.gz
		chown -R root:root $path/web
		;;
	* ) echo;;
esac
# fix buffer warning
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
