**Compile WiringPi**  
- download snapshot: https://git.drogon.net/?p=wiringPi;a=summary
- copy to RPi
```sh
tar -xzvf wiringPi-xxxxx.tar.gz -C ./wiringPi
rm wiringPi-xxxxx.tar.gz
cd wiringPi
./build
```
	
**Compile hddledPi**
```sh
cd /home/osmc
apt install libusb-dev
wget -q --show-progress -O actledPi.c "https://github.com/RagnarJensen/PiLEDlights/blob/master/hddledPi.c?raw=1"
gcc -Wall -O3 -o hddledPi hddledPi.c -lwiringPi
```
**Service file**  
create new **/lib/systemd/system/gpiohddled.service**
```sh
[Unit]
Description = HDD activity LED
After=systemd-modules-load.service

[Service]
ExecStart = /home/osmc/hddledPi

[Install]
WantedBy = multi-user.target
```

**Auto Startup** 
```sh
systemctl enable gpiohddled
```

**Start**  
		 -d, --detach						Detach from terminal (become a daemon)  
		 -p, --pin=VALUE			WiringPi pin number (default: 7)
		 -r, --refresh=VALUE	Refresh interval (default: 20 ms)  
```sh
./hddledPi -d
```

**Stop**
```sh
pkill -9 hddledPi
```
