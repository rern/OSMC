#!/bin/bash

wget -qN https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

title -l = "$bar Uninstall OSMC logo motd ..."

mv /etc/motd{.original,}
rm /etc/motd.banner
rm /etc/profile.d/motd.sh

title -nt "$info Relogin to see original motd."

rm $0
