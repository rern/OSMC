#!/usr/bin/python

# need root access to /dev/mem, /sys/module
# this script cannot run sudo by itself

import RPi.GPIO as GPIO
import json
import os
import sys

with open('/home/osmc/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)
	
on = gpio['on']
off = gpio['off']

on1 = int(on['on1'])
on2 = int(on['on2'])
on3 = int(on['on3'])
on4 = int(on['on4'])

onx = [on1, on2, on3, on4]
onx = [i for i in onx if i != 0]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(onx, GPIO.OUT)

if GPIO.input(onx[1]) == 0:
	os.system('/home/osmc/gpiooff.py 0')
	
if len(sys.argv) == 1: # no argument
	os.system('/usr/bin/xbmc-send -a "Powerdown"')
else: # with any argument
	os.system('/usr/bin/xbmc-send -a "Reboot"')
