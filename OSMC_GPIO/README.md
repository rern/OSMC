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

**Menu**  
- `Power` > `GPIO on` / `GPIO off` (OSMC default skin only)  
- Other skins: add the following to `DialogButtonMenu.xml` in that skin directory  
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
