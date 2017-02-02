#!/bin/bash

arg=$#

linered='\e[0;31m---------------------------------------------------------\e[m'
line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
osmcgpio=$( echo $(tput setaf 6)RuneUI GPIO$(tput setaf 7) )

# functions #######################################

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

# check installed #######################################

if [ ! -e /home/osmc/gpioon.py ]; then
	title "$info $osmcgpio not found."
	exit
fi

# gpio off #######################################
/home/osmc/gpiooff.py  > /dev/null 2>&1 &

title2 "Uninstall $osmcgpio ..."

title "$osmcgpio installed packages"
echo 'Uninstall Python-Pip, Python-Dev, GCC, PHP-FPM, NGINX, XZ Utils and RPi.GPIO:'
echo -e '  \e[0;36m0\e[m Uninstall'
echo -e '  \e[0;36m1\e[m Keep'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) echo
		title "Uninstall packages ..."
		pip uninstall -y RPi.GPIO
		apt remove --auto-remove -y x-utils nginx php5-fpm gcc python-dev python-pip
esac

title "Remove files ..."
rm -v /home/osmc/gpiooff.py
rm -v /home/osmc/gpiooffsudo.py
rm -v /home/osmc/gpioon.py
rm -v /home/osmc/gpioonsudo.py
rm -v /home/osmc/gpioset.py
rm -v /home/osmc/gpiotimer.py
rm -v /home/osmc/reboot.py
rm -v /home/osmc/rebootsudo.py
rm -v /home/osmc/poweroff.py
rm -v /home/osmc/poweroffsudo.py
rm -v /home/osmc/soundhdmi.py
rm -v /home/osmc/soundusb.py

rm -vr /var/www/html/gpio

title "Remove service ..."
systemctl disable gpioset
rm -v /lib/systemd/system/gpioset.service

titleend "$osmcgpio successfully uninstalled."

rm uninstall.sh
