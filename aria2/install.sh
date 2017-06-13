#!/bin/bash

# install.sh - run as root
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

label=$(e2label /dev/sda1)
title "$info Rename cuurent USB label, $label:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo
		echo 'New label: '
		read -n 1 label
		e2label /dev/sda1 $label
		;;
	* ) echo;;
esac

if ! grep -qs "/media/$label" /proc/mounts; then
	titleend "$info Hard drive not mount at /media/$label"
	exit
fi

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/uninstall_aria.sh
chmod +x uninstall_aria.sh

if ! type aria2c &>/dev/null; then
	title2 "Install Aria2 ..."
	apt install -y aria2
else
	title "$info Aria2 already installed."
fi
if ! type bsdtar &>/dev/null; then
	title "Install bsdtar ..."
	apt install -y bsdtar
fi
if ! type nginx &>/dev/null; then
	title "Install NGINX ..."
	apt install -y nginx
fi
title "Get WebUI files ..."
wget -qN --show-progress https://github.com/ziahamza/webui-aria2/archive/master.zip
mkdir /var/www/html/aria2
bsdtar -xf master.zip -s'|[^/]*/||' -C /var/www/html/aria2/
rm master.zip

mkdir -p /media/$label/aria2
[[ ! -e /root/.aria2 ]] && mkdir /root/.aria2
echo 'enable-rpc=true
rpc-listen-all=true
daemon=true
disable-ipv6=true
dir=/media/$label/aria2
max-connection-per-server=4
' > /root/.aria2/aria2.conf

echo '[Unit]
Description=Aria2
After=network-online.target
[Service]
Type=forking
ExecStart=/usr/bin/aria2c
[Install]
WantedBy=multi-user.target
' > /lib/systemd/system/aria2.service

echo 'server {
	listen 88;
	location / {
		root  /var/www/html/aria2;
		index  index.php index.html index.htm;
	}
}
' > /etc/nginx/sites-available/aria2
ln -s /etc/nginx/sites-available/aria2 /etc/nginx/sites-enabled/aria2

title "Restart nginx ..."
systemctl restart nginx

title "$info Start Aria2 on system startup:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl enable aria2;;
	* ) echo;;	
esac

title "$info Start Aria2 now:"
echo -e '  \e[0;36m0\e[m No'
echo -e '  \e[0;36m1\e[m Yes'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) systemctl start aria2;;
	* ) echo;;	
esac

title2 "Aria2 successfully installed."
echo 'Uninstall: ./uninstall_aria.sh'
echo 'Start: sudo systemctl start aria2'
echo 'Stop: sudo systemctl stop aria2'
echo 'Download directory: /media/$label/aria2'
titleend "WebUI: [OSMC_IP]:88"
