OSMC setup
---
**Settings**  
```bash
# customized file
gitpath=https://github.com/rern/OSMC/raw/master/_settings
path=/home/osmc/.kodi/userdata/addon_data/script.skinshortcuts
mkdir -p $path
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P $path
wget -qN --show-progress $gitpath/guisettings.xml -P /home/osmc/.kodi/userdata
touch /walkthrough_completed
systemctl restart mediacenter
```

**apt cache**
```
rm -r /var/cache/apt
mkdir -p /media/hdd/varcache/apt
ln -s /media/hdd/varcache/apt /var/cache/apt
```

**Aria2**
```
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh
```

**Transmission**
```
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh

rm -r /usr/share/transmission/web
ln -s /media/hdd/transmission/web /usr/share/transmission/web
```

**GPIO**
```bash
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
# customized file
wget -qN --show-progress $https://github.com/rern/OSMC/raw/master/_settings/gpio.json -P /home/osmc
```

**samba**
```bash
apt install samba
# customized file
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/smb.conf -P /etc/samba
systemctl restart nmbd
systemctl restart smbd

smbpasswd - a root
```
