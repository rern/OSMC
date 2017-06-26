#!/usr/bin/python
import json
import os
import sys
import time
import requests
import xml.dom.minidom as minidom

with open('/home/osmc/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)

timer = int(gpio['timer']['timer'])

xml = minidom.parse('/home/osmc/.kodi/userdata/guisettings.xml')
element = xml.getElementsByTagName('webserverport')
port = element[0].firstChild.nodeValue
	
payload = '{"jsonrpc":"2.0", "method":"XBMC.GetInfoBooleans", "params":{"booleans":["Player.Playing"]}, "id":1}'
	
interval = 60
i = timer
while i > 0:
	time.sleep(interval)
	response = requests.post('http://localhost:'+ port +'/jsonrpc', data=payload, headers={'content-type': 'application/json'}).json()
	playing = response['result']['Player.Playing']
	if playing == True:
		i = timer
	else:
		i -= 1
		if i == 1:
			os.system('/usr/bin/xbmc-send -a "Notification(GPIO, Idle Timer OFF in '+ str(interval) +' seconds, 10000)"')
			time.sleep(interval - 10)
			os.system('/usr/bin/xbmc-send -a "Notification(GPIO, Idle Timer OFF in 10 seconds, 10000)"')
			time.sleep(10)
			os.system("/usr/bin/sudo /home/osmc/gpiooff.py &> /dev/null &")
