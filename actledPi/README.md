**Compile actledPi**
```sh
cd /home/osmc
apt install libusb-dev
wget -q --show-progress -O actledPi.c "https://github.com/RagnarJensen/PiLEDlights/blob/master/actledPi.c?raw=1"
gcc -Wall -O3 -o actledPi actledPi.c
```

**Service file**  
create new **/lib/systemd/system/gpioactled.service**
```sh
[Unit]
Description = GPIO activity LED
After=systemd-modules-load.service

[Service]
ExecStart = /home/osmc/actledPi

[Install]
WantedBy = multi-user.target
```

**Auto Startup** 
```sh
systemctl enable gpioactled
```

**RPi config**  
append **/boot/config.txt**  
```sh
dtoverlay=pi3-act-led,gpio=21
```

**Start**  
		 -d, --detach						Detach from terminal (become a daemon)  
		 -r, --refresh=VALUE	Refresh interval (default: 20 ms)  
```sh
./actledPi -d
```

**Stop**
```sh
pkill -9 actledPi
```
