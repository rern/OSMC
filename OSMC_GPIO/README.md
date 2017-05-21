OSMC_GPIO
---

![screen0](https://github.com/rern/Assets/blob/master/OSMC_GPIO/kodigpio.jpg)  

**Install**
```sh
wget -q --show-progress -O install.sh "https://github.com/rern/OSMC/blob/master/OSMC_GPIO/install.sh?raw=1"; chmod +x install.sh; ./install.sh
```

**Settings**  
Browser: [OSMC IP]/gpiosettings.php (eg: 192.168.1.11/gpiosettings.php)  

![gpio](https://github.com/rern/Assets/blob/master/OSMC_GPIO/gpio.jpg)  

**Control**  
- Keyboard / Remote control: add the following to on / off buttons in `keyboard.xml` / `remote.xml`  
```xml
<key1>RunScript(/home/osmc/gpioonsudo.py)</key1>
<key2>RunScript(/home/osmc/gpiooffsudo.py)</key2>
```

- Menu: add the following to `DialogButtonMenu.xml` > before `<item><label>Restart`  in skin directory  
```xml
<item>
	<label>GPIO On</label>
	<onclick>RunScript(/home/osmc/gpioonsudo.py)</onclick>
	<visible>System.CanReboot</visible>
</item>
<item>
	<label>GPIO Off</label>
	<onclick>RunScript(/home/osmc/gpiooffsudo.py)</onclick>
	<visible>System.CanReboot</visible>
</item>
```
