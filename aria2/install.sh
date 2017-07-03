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

if type aria2c &>/dev/null; then
	titleend "$info Aria2 already installed."
	exit
fi

if (( $# == 0 )); then
	# user input
	title "$info Start Aria2 on system startup:"
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 ansstartup
	echo
else
	ansstartup=1
fi

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/uninstall_aria.sh
chmod +x uninstall_aria.sh

title2 "Install Aria2 ..."
# skip with any argument
(( $# == 0 )) && apt update
apt install -y aria2

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
mkdir -p /var/www/html/aria2
bsdtar -xf master.zip -s'|[^/]*/||' -C /var/www/html/aria2/
rm master.zip

if mount | grep '/dev/sda1' &>/dev/null; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	mkdir -p $mnt/aria2
	path=$mnt/aria2
else
	mkdir -p /root/aria2
	path=/root/aria2
fi
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

# start
[[ $ansstartup == 1 ]] && systemctl enable aria2
title "Start Aria2 ..."
systemctl start aria2

title2 "Aria2 installed and started successfully."
echo 'Uninstall: ./uninstall_aria.sh'
echo 'Start: sudo systemctl start aria2'
echo 'Stop: sudo systemctl stop aria2'
echo 'Download directory: '$path
titleend "WebUI: [OSMC_IP]:88"
