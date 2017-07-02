OSMC setup
---

This is just an example of setup script.  

[**setup.sh**](https://github.com/rern/OSMC/blob/master/_settings/setup.sh)
- set hdmi mode
- set `fstab` for usb drive (fix automount to `/media/hdd_`)
- set package cache to usb to avoid slow download on os reinstall
- restore settings
- upgrage and customize **samba** to improve speed
- make usb drive a common between os for `smb.conf`
- install **Transmission**
- install **Aria2**
- install **OSMC GPIO**
- make usb drive a common between os for `gpio.json`
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh; chmod +x setup.sh; ./setup.sh
```
