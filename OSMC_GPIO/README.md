OSMC_GPIO
---
![screen0](https://github.com/rern/OSMC/blob/master/OSMC_GPIO/_repo/kodigpio.jpg)  

**Install**
```sh
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/OSMC_GPIO/install.sh; chmod +x install.sh; ./install.sh
```

**Settings**  
Edit: `/home/osmc/gpio.json`  

**Control**  
- Keyboard / Remote control: add the following to on / off buttons in `keyboard.xml` / `remote.xml`  
```xml
<key1>RunScript(/home/osmc/gpioonsudo.py)</key1>
<key2>RunScript(/home/osmc/gpiooffsudo.py)</key2>
```

- Menu: add the following to `DialogButtonMenu.xml` in skin directory  
```xml
<!-- within <content> ... </content> -->
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
