#!/bin/bash

# install.sh [startup]
#   [startup] = 1 / null
#   any argument = no prompt + no package update

# import heading function
wget -qN https://github.com/rern/tips/raw/master/bash/f_heading.sh; . f_heading.sh; rm f_heading.sh

rm install.sh

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

if mount | grep '/dev/sda1' &>/dev/null; then
	mnt=$( mount | grep '/dev/sda1' | awk '{ print $3 }' )
	mkdir -p $mnt/aria2
	path=$mnt/aria2
else
	mkdir -p /root/aria2
	path=/root/aria2
fi
if (( $# == 0 )); then
	title "Get WebUI files ..."
	wget -qN --show-progress https://github.com/ziahamza/webui-aria2/archive/master.zip
	mkdir -p $path/web
	bsdtar -xf master.zip -s'|[^/]*/||' -C $path/web
	rm master.zip
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

echo 'server { #aria2
	listen 88;
	location / {
		root  '$path'/web;
		index  index.php index.html index.htm;
	}
} #aria2
' >> /etc/nginx/sites-available/aria2
ln -s /etc/nginx/sites-available/aria2 /etc/nginx/sites-enabled/aria2

title "Restart nginx ..."
systemctl restart nginx

# start
[[ $ansstartup == 1 ]] && systemctl enable aria2
title "Start Aria2 ..."
systemctl start aria2

title2 Aria2 installed and started successfully.
echo Uninstall: ./uninstall_aria.sh
echo Run: sudo systemctl [ start /stop ] aria2
echo Startup: sudo systemctl [ enable /disable ] aria2
echo
echo Download directory: $path
titleend "WebUI: [OSMC_IP]:88"
