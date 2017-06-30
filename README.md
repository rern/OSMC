OSMC setup
---

This is just an example of setup script.  

[**setup.sh**](https://github.com/rern/OSMC/blob/master/_settings/setup.sh)
- set package cache to usb to avoid slow download on os reinstall
- disable unused cec
- restore settings
- upgrage and customize **samba** to improve speed
- make usb drive a common between os for `smb.conf`
- install **Aria2**
- install **Transmission**
- make usb drive a common between os for web, `settings.json`, directory
- install **OSMC GPIO**
- make usb drive a common between os for `gpio.json`

```
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh; chmod +x setup.sh; ./setup.sh
```
