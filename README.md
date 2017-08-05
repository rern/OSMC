OSMC setup
---

[**setup.sh**](https://github.com/rern/OSMC/blob/master/_settings/setup.sh)
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/_settings/setup.sh; chmod +x setup.sh; ./setup.sh
```

This is just an example of setup script.  
- set password for Samba and Transmission
- set package cache to usb to avoid slow download on os reinstall
- upgrage and customize **Samba** to improve speed
- install **Transmission**
- install **Aria2**
- install **OSMC GPIO**

**User setting files**  
`/home/osmc/.kodi/userdata/advancedsettings.xml` - hide directories from scanning / listing  
`/home/osmc/.kodi/userdata/guisettings.xml` - all settings  
- `<esallinterfaces>true</esallinterfaces>` - Allow remote control from applications on other systems

**RunScript()**  
Kodi has trouble `RunScript()` with bash `*.sh` - use python `*.py` instead  
