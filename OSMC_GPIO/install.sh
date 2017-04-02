#!/bin/bash

# install.sh - run as root

line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
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
title "$info Update package databases"
echo -e '  \e[0;36m0\e[m Skip'
echo -e '  \e[0;36m1\e[m Update'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	* ) echo;;
	1 ) echo
		title "Update package databases ..."
		apt update
esac

if ! dpkg -s python-pip > /dev/null 2>&1; then
	title "Install Python-Pip ..."
	apt install -y python-pip
fi
if ! dpkg -s python-dev > /dev/null 2>&1; then
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
if ! dpkg -s bsdtar > /dev/null 2>&1; then
	title "Install bsdtar ..."
	apt install -y bsdtar
fi

if ! python -c "import RPi.GPIO" > /dev/null 2>&1; then
	title "Install Python-RPi.GPIO ..."
	yes | pip install RPi.GPIO
fi

# install OSMC GPIO #######################################
title "Get files ..."

wget -q --show-progress -O uninstall.sh "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/uninstall.sh?raw=1"
wget -q --show-progress -O OSMC_GPIO.tar.xz "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/_repo/OSMC_GPIO.tar.xz?raw=1"
chmod 755 uninstall.sh

title "Install files ..."
bsdtar -xvf OSMC_GPIO.tar.xz -C / $([ ! -f /home/osmc/gpio.json ] && echo '--exclude=gpio.json')
rm OSMC_GPIO.tar.xz

chmod 755 /home/osmc/*.py
chmod 666 /home/osmc/gpio.json
chmod 755 /var/www/html/gpio/*.php

chmod 644 /etc/udev/rules.d/usbsound.rules
udevadm control --reload

# set initial gpio #######################################
/home/osmc/gpioset.py
systemctl enable gpioset

# modify shutdown menu #######################################
file='/tmp/mount/usr/share/kodi/addons/skin.osmc/16x9/DialogButtonMenu.xml'
#line=$(sed -n '/Quit()/{=}' $file)
line=$(( $line - 3 ))
sed -i -e ''"$line"' i\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>GPIO On</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/gpioon.py)</onclick>\
\t\t\t\t\t\t<visible>System.CanReboot</visible>\
\t\t\t\t\t</item>\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>GPIO Off</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/gpiooff.py)</onclick>\
\t\t\t\t\t\t<visible>System.CanReboot</visible>\
\t\t\t\t\t</item>
' $file
title2 "$osmcgpio successfully installed."
echo $info 'Browser: [OSMC_IP]/gpio/ for settings.'
titleend "To uninstall:   ./uninstall.sh"
