# USB DAC hot plug
Auto Switch Audio Output with udev for RPi OSMC  
  
(Tested on RPi3)    
#
- Plug in / Turn on USB DAC --- auto switch audio output to USB DAC
- Unplug / Turn off USB DAC --- auto swith audio output to HDMI  

**Get /device/path**  
```sh
sudo udevadm monitor --udev
```
- plug in / turn on USB DAC
- copy /devices/path.../card1  

**Get device parameter**  
```sh
sudo udevadm info --path=/devices/path.../card1 --attribute-walk
```
- copy 'KERNEL' and 'SUBSYSTEM' for rules  

**Create hot plug rules**  
/etc/udev/rules.d/usbsound.rules  
```sh
ACTION=="add", KERNEL=="controlC1", SUBSYSTEM=="sound", RUN+="/home/osmc/usbsound.sh"
ACTION=="remove", KERNEL=="controlC1", SUBSYSTEM=="sound", RUN+="/home/osmc/hdmisound.sh"
```

**Test rules**
```sh
udevadm test /devices/path.../card1
```

**Create json-rpc command files**  
change 'audiooutput' in 'guisettings.xml'  
/home/osmc/usbsound.sh  
```sh
#!/bin/bash

# auto switch for single usb sound only

# get http 'port' >>> as may be changed by user
port=$(sed -n 's:.*>\(.*\)</webserverport>.*:\1:p' /home/osmc/.kodi/userdata/guisettings.xml)

# get usb 'id' >>> /dev/snd/controlC1 == /sys/devices/platform/soc/3f980000.usb/usb1/1-1/1-1.[1 to 4]/...
# (get usb path | sed path to '...card1/id' | prepend '/sys' dir to path) >>> get file content
path=$(udevadm info -n /dev/snd/controlC1 -q path | sed 's/controlC1/id/' | sed 's/^/\/sys/')
id=$(< $path)

# [{set audio output to usb 'id'}, {notify}] http 'port'
curl -H "Content-type: application/json" -X POST -d '[
	{"jsonrpc":"2.0", 
		"method":"Settings.SetSettingValue", 
		"params":{"setting":"audiooutput.audiodevice", 
			"value":"ALSA:@:CARD='$id',DEV=0"}, 
	"id":1},
	{"jsonrpc":"2.0", 
		"method":"GUI.ShowNotification", 
		"params":{"title":"AUDIO OUTPUT", 
			"message":"Switched to USB Sound"}, 
	"id":1}
]' http://localhost:$port/jsonrpc
```

**Create unplug notification**  
/home/osmc/hdmisound.sh  
```sh
#!/bin/bash

# auto swith back to hdmi by system default, notify only

# get http 'port'
port=$(sed -n 's:.*>\(.*\)</webserverport>.*:\1:p' /home/osmc/.kodi/userdata/guisettings.xml)

# notify with http 'port'
curl -H "Content-type: application/json" -X POST -d '{
	"jsonrpc":"2.0",
	"method":"GUI.ShowNotification", 
	"params":{"title":"AUDIO OUTPUT", 
		"message":"Switched to HDMI"}, 
	"id":1
}' http://localhost:$port/jsonrpc
```

**Set files permission**  
```sh
sudo chmod +x /home/osmc/hdmisound.sh usbsound.sh
```
