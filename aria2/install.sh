#!/bin/bash

# install.sh [startup]
#   [startup] = 1 / null
#   any argument = no prompt + no package update

rm $0

# import heading function
wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

if type aria2c &>/dev/null; then
	title "$info Aria2 already installed."
	exit
fi

if (( $# == 0 )); then
	# user input
	title "$info Start Aria2 on system startup:"
	echo -e "  \e[0;36m0\e[m No"
	echo -e "  \e[0;36m1\e[m Yes"
	echo
	echo -e "\e[0;36m0\e[m / 1 ? "
	read -n 1 ansstartup
	echo
else
	ansstartup=1
fi

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/uninstall_aria.sh
chmod +x uninstall_aria.sh

title -l = "$bar Install Aria2 ..."
# skip with any argument
if (( $# == 0 )); then
	title "Update package databases..."
	apt update
fi

apt install -y aria2
if ! type bsdtar &>/dev/null; then
	title "Install bsdtar ..."
	apt install -y bsdtar
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
# link to kodi web root
ln -s $path/web /usr/share/kodi/addons/webinterface.default/aria2
# change webui port to 80
sed -i 's/8080/80/g' /home/osmc/.kodi/userdata/guisettings.xml
systemctl restart mediacenter

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

# start
[[ $ansstartup == 1 ]] && systemctl enable aria2
title "Start Aria2 ..."
systemctl start aria2

title -l = "$bar Aria2 installed and started successfully."
echo "Uninstall: ./uninstall_aria.sh"
echo
echo "Run: sudo systemctl [ start /stop ] aria2"
echo "Startup: sudo systemctl [ enable /disable ] aria2"
echo
echo "Download directory: $path"
echo "$info OSMC web interface changed to port:80"
title -nt "WebUI: [OSMC_IP]/aria2/"
