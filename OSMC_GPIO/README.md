OSMC_GPIO
---
![screen0](https://github.com/rern/OSMC/blob/master/OSMC_GPIO/_repo/kodigpio.jpg)  

**Features**
- Power `on` `off` audio equipments in sequence
- delay setting for each equipment(relay)
- Notification for `on` `off`
- Idle timer power off by polling 'play' status every minute with last minute warning
- Auto power off on reboot / shutdown

**Install**
```sh
wget -qN --show-progress https://raw.githubusercontent.com/rern/OSMC/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
```

**Settings**  
Edit: `/home/osmc/gpio.json`  

**Control**  
- Keyboard / Remote control: add the following to on / off buttons in `keyboard.xml` / `remote.xml`  
```xml
<key1>RunScript(/home/osmc/gpioon.py)</key1>
<key2>RunScript(/home/osmc/gpiooff.py)</key2>
```

- Menu: add the following to `DialogButtonMenu.xml` in skin directory  
```xml
<!-- within <content> ... </content> -->
	<item>
		<label>GPIO On</label>
		<onclick>RunScript(/home/osmc/gpioon.py)</onclick>
		<visible>System.CanReboot</visible>
	</item>
	<item>
		<label>GPIO Off</label>
		<onclick>RunScript(/home/osmc/gpiooff.py)</onclick>
		<visible>System.CanReboot</visible>
	</item>
```

**/dev/gpiomem**  
`usermod -a -G root osmc` group permission for osmc  
`chmod g+rw /dev/gpiomem` on startup (reset to rw------- every boot)  
