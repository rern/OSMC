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

# install OSMC GPIO #######################################
title "Get files ..."

wget -q --show-progress -O OSMC_GPIO.tar.xz "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/_repo/OSMC_GPIO.tar.xz?raw=1"
wget -q --show-progress -O uninstall.sh "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/uninstall.sh?raw=1"
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

# install packages #######################################
apt update

if ! dpkg -s python-pip > /dev/null 2>&1; then
	title "Install Python-Pip ..."
	apt install -y python-pip
fi
if ! dpkg -s php5-fpm > /dev/null 2>&1; then
	title "Install Python-Dev ..."
	apt install -y python-dev
fi
if ! dpkg -s gcc > /dev/null 2>&1; then
	title "Install GCC ..."
	apt install -y gcc
fi
if ! dpkg -s php5-fpm > /dev/null 2>&1; then
	title "Install PHP-FPM ..."
	apt install -y php5-fpm
fi
if ! dpkg -s nginx > /dev/null 2>&1; then
	title "Install NGINX ..."
	apt install -y nginx
fi
if ! dpkg -s xz-utils > /dev/null 2>&1; then
	title "Install XZ Utils ..."
	apt install -y xz-utils
fi

if ! python -c "import RPi.GPIO" > /dev/null 2>&1; then
	title "Install Python-RPi.GPIO ..."
	pip install -y RPi.GPIO
fi

# set initial gpio #######################################
/home/osmc/gpioset.py
systemctl enable gpioset

title2 "$osmcgpio successfully installed."
echo $info 'Browser: [OSMC_IP]/gpio/ for settings.'
titleend "To uninstall:   ./uninstall.sh"
