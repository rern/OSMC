#!/bin/bash

wget -qN --show-progress https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

if [[ ! -e /etc/motd.logo ]]; then
  echo -e "$info OSMC logo motd not found."
  exit
fi

title -l = "$bar Uninstall OSMC logo motd ..."

echo -e "$bar Restore files ..."

mv /etc/motd{.original,}
rm /etc/motd.logo /etc/profile.d/motd.sh

sed -i -e '/^PS1=/ d
' -e '/^#PS1=/ s/^#//
' /etc/bash.bashrc

title -l = "$bar OSMC logo motd uninstalled successfully."
title -nt "\n$info Relogin to see original motd."

rm $0
