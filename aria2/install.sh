#!/bin/bash

# install.sh - run as root

line='\e[0;36m---------------------------------------------------------\e[m'
title() {
		echo -e "\n$line"
		echo $1
		echo -e "$line\n"
}
titleend() {
		echo -e "\n$1"
		echo -e "\n$line\n"
}

rm install.sh

title "Install Aria2 ..."
apt-get install -y aria2
if ! dpkg -s unzip > /dev/null 2>&1; then
	title "Install unzip ..."
	apt-get install -y unzip
fi
if ! dpkg -s nginx > /dev/null 2>&1; then
	title "Install NGINX ..."
	apt-get install -y nginx
fi
title "Get WebUI files ..."
wget -O aria2.zip https://github.com/ziahamza/webui-aria2/archive/master.zip
unzip aria2.zip -d /var/www/html/
rm aria2.zip

mkdir /root/.aria2
echo 'enable-rpc=true
rpc-listen-all=true
daemon=true
disable-ipv6=true
' > /root/.aria2/aria2.conf

echo 'server {
	listen 88;
	location / {
		root  /var/www/html/webui-aria2-master;
		index  index.php index.html index.htm;
	}
}
' /etc/nginx/sites-available/aria2
ln -s /etc/nginx/sites-available/aria2 /etc/nginx/sites-enable/aria2

title "Restart nginx ..."
systemctl restart nginx

title "Aria2 successfully installed."
echo "Start Aria2: aria2c --conf-path=/etc/aria2.conf"
titleend "WebUI: [RuneAudio_IP]:88"
