OSMC
---

**apt cache**
```sh
rm -r /var/cache/apt
ln -s /var/cache/apt /media/hdd/varcache/apt
apt update
```

**Aria2**
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/aria2/install.sh; chmod +x install.sh; ./install.sh
```

**samba**
```sh
apt install samba
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/samba/smb.conf
systemctl restart nmbd
systemctl restart smbd
```

**Transmission**
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh
```

**GPIO**
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
```
