#!/bin/bash

# install.sh - run as root

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
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

rm install.sh

wget -q --show-progress -O uninstall_aria.sh "https://github.com/rern/RuneAudio/blob/master/transmission/uninstall_aria.sh?raw=1"
chmod +x uninstall_aria.sh

if ! dpkg -s aria2 > /dev/null 2>&1; then
	title2 "Install Aria2 ..."
	apt install -y aria2
else
	title "$info Aria2 already installed."
fi
if ! dpkg -s unzip > /dev/null 2>&1; then
	title "Install unzip ..."
	apt install -y unzip
fi
if ! dpkg -s nginx > /dev/null 2>&1; then
	title "Install NGINX ..."
	apt install -y nginx
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
' > /etc/nginx/sites-available/aria2
ln -s /etc/nginx/sites-available/aria2 /etc/nginx/sites-enabled/aria2

title "Restart nginx ..."
systemctl restart nginx

title2 "Aria2 successfully installed."
echo "Uninstall: ./uninstall_aria.sh"
echo "Start Aria2: aria2c --conf-path=/etc/aria2.conf"
titleend "WebUI: [OSMC_IP]:88"
