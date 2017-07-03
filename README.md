OSMC setup
---

This is just an example of setup script.  

[**setup.sh**](https://github.com/rern/OSMC/blob/master/_settings/setup.sh)
- set password for Samba and Transmission
- set package cache to usb to avoid slow download on os reinstall
- upgrage and customize **Samba** to improve speed
- install **Transmission**
- install **Aria2**
- install **OSMC GPIO**
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh; chmod +x setup.sh; ./setup.sh
```

note: uninstall nginx must use `purge` with all 3 packages
```sh
apt purge nginx nginx-common nginx-full
```
