#!/bin/bash

wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh

title -l = "$bar Uninstall OSMC logo motd ..."

mv /etc/motd{.original,}
rm /etc/motd.logo /etc/profile.d/motd.sh

sed -i -e '/^PS1=/ d
' -e '/^#PS1=/ s/^#//
' /etc/bash.bashrc

title -nt "\n$info Relogin to see original motd."

rm $0
