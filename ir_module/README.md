**/boot/config.txt** - add config  
```sh
dtoverlay=lirc-rpi
dtparam=gpio_in_pin=21
```

**Stop service**
```sh
systemctl stop lircd_helper@lirc0
```

**Get BTN_? / KEY_? list**
```sh
irrecord --list-namespace
```

**Detect ir**
```sh
irrecord -d /dev/lirc0 /home/osmc/lircd.conf
```

**Start service**
```sh
systemctl start lircd_helper@lirc0
```
	
**Customize command**
```sh
nano /home/osmc/.kodi/userdata/keymaps/remote.xml
```
