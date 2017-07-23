#!/bin/bash

# install.sh - run as root

# import heading function
wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh
osmcgpio=$( tcolor "OSMC GPIO" )

rm install.sh

# check installed #######################################
if [ -e /home/osmc/gpioon.py ]; then
	title "$info $osmcgpio already installed"
	exit
fi

title -l = "$bar Install $osmcgpio ..."

# install packages #######################################
# skip with any argument
if (( $# == 0 )); then
	title "Update package databases ..."
	apt update
fi
if ! dpkg -s python-pip 2>/dev/null | grep 'Status: install ok installed' &>/dev/null; then
	title "Install Python-Pip ..."
	apt install -y python-pip
fi
if ! dpkg -s python-dev 2>/dev/null | grep 'Status: install ok installed' &>/dev/null; then
	title "Install Python-Dev ..."
	apt install -y python-dev
fi
if ! type gcc &>/dev/null; then
	title "Install GCC ..."
	apt install -y gcc
fi
if ! type bsdtar &>/dev/null; then
	title "Install bsdtar ..."
	apt install -y bsdtar
fi

if ! python -c "import RPi.GPIO" &>/dev/null; then
	title "Install Python-RPi.GPIO ..."
	yes | pip install RPi.GPIO
fi

# install OSMC GPIO #######################################
title "Get files ..."

wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/uninstall_gpio.sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/_repo/OSMC_GPIO.tar.xz
chmod 755 uninstall_gpio.sh

# mod files
if [[ -e /home/osmc/rebootosmc.py ]]; then
	sed -i "/rebootosmc.sh/ i\os.system('/usr/bin/sudo /home/osmc/gpiooffsudo.py r &')" /home/osmc/rebootosmc.py
	sed -i "/rebootrune.sh/ i\os.system('/usr/bin/sudo /home/osmc/gpiooffsudo.py r &')" /home/osmc/rebootrune.py
fi

title "Install files ..."
bsdtar -xvf OSMC_GPIO.tar.xz -C / $([ -f /home/osmc/gpio.json ] && echo ' --exclude=gpio.json')
rm OSMC_GPIO.tar.xz

chmod 755 /home/osmc/*.py
chmod 666 /home/osmc/gpio.json

chmod 644 /etc/udev/rules.d/usbsound.rules
udevadm control --reload

# set initial gpio #######################################
systemctl daemon-reload
systemctl enable gpioset
systemctl start gpioset

# modify shutdown menu #######################################
file='/usr/share/kodi/addons/skin.osmc/16x9/DialogButtonMenu.xml'
if ! grep 'gpioonsudo.py' $file &> /dev/null; then
	linenum=$( sed -n '/Quit()/{=}' $file ) # normal
	sed -i -e "$(( $linenum - 2 ))"' i\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>GPIO On</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/gpioonsudo.py)</onclick>\
\t\t\t\t\t</item>\
\t\t\t\t\t<item>\
\t\t\t\t\t\t<label>GPIO Off</label>\
\t\t\t\t\t\t<onclick>RunScript(/home/osmc/gpiooffsudo.py)</onclick>\
\t\t\t\t\t</item>
	' $file
fi

title -l = "$bar $osmcgpio installed successfully."
echo "Uninstall: ./uninstall_gpio.sh"
echo
echo 'Setting: /home/osmc/gpio.json'
title -nt "Power menu > GPIO On / GPIO Off"
