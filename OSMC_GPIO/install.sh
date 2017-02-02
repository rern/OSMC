#!/bin/bash

# install.sh - run as root

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
osmcgpio=$( echo $(tput setaf 6)OSMC GPIO$(tput setaf 7) )
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

title2 "Install $osmcgpio ..."

# install packages #######################################
apt-get update

apt-get install -y python-pip python-dev gcc

if ! dpkg -s python-pip > /dev/null 2>&1; then
	title "Install Python-Pip ..."
	apt-get install -y python-pip
fi
if ! dpkg -s php5-fpm > /dev/null 2>&1; then
	title "Install Python-dev ..."
	apt-get install -y python-dev
fi
if ! dpkg -s gcc > /dev/null 2>&1; then
	title "Install gcc ..."
	apt-get install -y gcc
fi

pip install -y rpi.gpio

if ! dpkg -s php5-fpm > /dev/null 2>&1; then
	title "Install PHP ..."
	apt-get install -y php5-fpm
fi
if ! dpkg -s nginx > /dev/null 2>&1; then
	title "Install NGINX ..."
	apt-get install -y nginx
fi
if ! dpkg -s xz-utils > /dev/null 2>&1; then
	title "Install xz-utils ..."
	apt-get install -y xz-utils
fi

sed -i '/# location \~ \\.php$ {/ i\
    location ~ \\\.php$ {\
        fastcgi_pass unix:/var/run/php5-fpm.sock;\
        fastcgi_index index.php;\
        include fastcgi_params;\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\
    };\
    s/index index.html/index index.html index.php/
' /etc/nginx/sites-available/default

service php5-fpm restart
service nginx restart

# install OSMC GPIO #######################################
title "Get files ..."

wget -q --show-progress -O OSMC_GPIO.tar.xz "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/_repo/OSMC_GPIO.tar.xz?raw=1"
wget -q --show-progress -O uninstall.sh "https://github.com/rern/RuneUI_GPIO/blob/master/OSMC_GPIO/uninstall.sh?raw=1"
chmod 755 uninstall.sh

title "Install files ..."
if [ ! -f /home/osmc/gpio.json ]; then
	tar -Jxvf OSMC_GPIO.tar.xz -C /
else
	tar -Jxvf OSMC_GPIO.tar.xz -C / --exclude='home/osmc/gpio.json' 
fi
rm OSMC_GPIO.tar.xz

chmod 755 /home/osmc/*.py
chmod 666 /home/osmc/gpio.json
chmod 755 /var/www/html/gpio/*.php

/home/osmc/gpioset.py
systemctl enable gpioset

title2 "$osmcgpio successfully installed."
echo $info 'Browser: [OSMC_IP]/gpio/ for settings.'
titleend "To uninstall:   ./uninstall.sh"
