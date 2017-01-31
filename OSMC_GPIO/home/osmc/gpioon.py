#!/usr/bin/python
import RPi.GPIO as GPIO
import json
import os

with open('/home/osmc/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)

on = gpio['on']

on1 = int(on['on1'])
ond1 = int(on['ond1'])
on2 = int(on['on2'])
ond2 = int(on['ond2'])
on3 = int(on['on3'])
ond3 = int(on['ond3'])
on4 = int(on['on4'])

onx = [on1, on2, on3, on4]
onx = [i for i in onx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(onx, GPIO.OUT)

if GPIO.input(onx[1]) == 0:
	os.system('/usr/bin/xbmc-send -a "Notification(GPIO,Already ON)"')
else:
	import time

	if on1 != 0:
		GPIO.output(on1, 0)
	if on2 != 0:
		time.sleep(ond1)
		GPIO.output(on2, 0)
	if on3 != 0:
		time.sleep(ond2)
		GPIO.output(on3, 0)
	if on4 != 0:
		time.sleep(ond3)
		GPIO.output(on4, 0)
	
	os.system('/usr/bin/sudo /home/osmc/gpiotimer.py > /dev/null 2>&1 &')
