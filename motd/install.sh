#!/bin/bash

rm $0

wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

title -l = "$bar Install OSMC logo motd ..."
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/motd/uninstall_motd.sh; chmod +x uninstall_motd.sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/motd/motd.logo -P /etc

mv /etc/motd{,.original}

echo '#!/bin/bash

color=33

echo -e "\e[38;5;${color}m$( < /etc/motd.logo )\e[0m"
'> /etc/profile.d/motd.sh

sed -i -e '/^PS1=/ s/^/#/
' -e '/PS1=/ a\
color=242\
PS1=\x27\\[\\e[38;5;\x27$color\x27m\\]\\u@\\h:\\[\\e[0m\\]\\w \\$ \x27
' /etc/bash.bashrc
# PS1='\[\e[38;5;'$color'm\]\u@\h:\[\e[0m\]\w \$ '
# \[ \] - omit charater count when press <home> key

echo -e "\nUninstall: ./uninstall_motd.sh"
title -nt "$info Relogin to see new OSMC logo motd."
