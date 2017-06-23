OSMC setup
---

This is just an example for settings on a [Dual Boot](https://github.com/rern/RPi2-3.Dual.Boot-Rune.OSMC) system with some packages installed.  

**All setup**
```
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh; chmod +x setup.sh; ./setup.sh
```
---

**apt cache**
```
rm -r /var/cache/apt
mkdir -p /media/hdd/varcache/apt
ln -s /media/hdd/varcache/apt /var/cache/apt
```

**Settings**  
```bash
# 'skin shortcuts' addon
apt update
apt install -y bsdtar
wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip
bsdtar -xf master.zip -C /home/osmc/.kodi/addons
mv /home/osmc/.kodi/addons/script.skinshortcuts-master /home/osmc/.kodi/addons/script.skinshortcuts
rm master.zip

# customized file
gitpath=https://github.com/rern/OSMC/raw/master/_settings
wget -qN --show-progress $gitpath/mainmenu.DATA.xml -P /home/osmc/.kodi/userdata/addon_data/script.skinshortcuts
wget -qN --show-progress $gitpath/guisettings.xml -P /home/osmc/.kodi/userdata

touch /walkthrough_completed
systemctl restart mediacenter
```

**samba**
```bash
apt install samba
# customized file
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/smb.conf -P /etc/samba
systemctl restart nmbd
systemctl restart smbd

smbpasswd -a root
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
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/gpio.json -P /home/osmc
```
