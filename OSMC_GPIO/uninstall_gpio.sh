#!/bin/bash

arg=$#

line2=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' = )
line=$( printf '\e[0;36m%*s\e[m\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
osmcgpio=$( echo $(tput setaf 6)OSMC GPIO$(tput setaf 7) )

title2() {
	echo $line2
	echo -e "$bar $1"
	echo $line2
}
title() {
	echo $line
	echo -e "$1"
	echo $line
}
titleend() {
	echo -e "\n$1"
	echo $line
}

# check installed #######################################

if [ ! -e /home/osmc/gpioon.py ]; then
	title "$info $osmcgpio not found."
	exit
fi

# gpio off #######################################
/home/osmc/gpiooff.py &>/dev/null &

title2 "Uninstall $osmcgpio ..."

title "$osmcgpio installed packages"
echo 'Uninstall Python-Pip, Python-Dev, GCC, PHP-FPM, NGINX, bsdtar and RPi.GPIO:'
echo -e '  \e[0;36m0\e[m Uninstall'
echo -e '  \e[0;36m1\e[m Keep'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) echo
		title "Uninstall packages ..."
		python -c "import RPi.GPIO" &>/dev/null && pip uninstall -y RPi.GPIO
		dpkg -s bsdtar | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y bsdtar
		dpkg -s nginx | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y nginx
		dpkg -s php5-fpm | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y php5-fpm
		dpkg -s gcc | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y gcc
		dpkg -s python-dev | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y python-dev
		dpkg -s python-pip | grep 'Status: install ok installed' &>/dev/null && apt remove --purge --auto-remove -y python-pip
esac

# remove files
title "Remove files ..."
rm -v /home/osmc/gpiooff.py
rm -v /home/osmc/gpiooffsudo.py
rm -v /home/osmc/gpioon.py
rm -v /home/osmc/gpioonsudo.py
rm -v /home/osmc/gpioset.py
rm -v /home/osmc/gpiotimer.py
rm -v /home/osmc/poweroff.py
rm -v /home/osmc/poweroffsudo.py
rm -v /home/osmc/rebootsudo.py
rm -vr /var/www/html/gpio

# restore backup files
if [[ -e /home/osmc/rebootosmc.py ]]; then
	sed -i '/gpiooffsudo.py/d' /home/osmc/rebootosmc.py
	sed -i '/gpiooffsudo.py/d' /home/osmc/rebootrune.py
fi

title "Remove service ..."
systemctl disable gpioset
rm -v /lib/systemd/system/gpioset.service

# modify shutdown menu #######################################
file='/usr/share/kodi/addons/skin.osmc/16x9/DialogButtonMenu.xml'

if grep 'gpioonsudo' $file &>/dev/null; then
	linenum=$( sed -n '/gpioonsudo/{=}' $file ) # normal
	sed -i "$(( $linenum - 2 )), $(( $linenum + 1 )) d" $file
fi
if grep 'gpiooffsudo' $file &>/dev/null; then
	linenum=$( sed -n '/gpiooffsudo/{=}' $file ) # normal
	sed -i "$(( $linenum - 2 )), $(( $linenum + 1 )) d" $file
fi

echo 'Nginx still installed.'
echo 'Remove: apt purge nginx nginx-common nginx-full'
titleend "$osmcgpio successfully uninstalled."

rm uninstall.sh
