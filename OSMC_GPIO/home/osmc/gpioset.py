#!/usr/bin/python
import RPi.GPIO as GPIO
import json

with open('/home/osmc/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)

pin = gpio['pin'] # get data as key['value']

pin1 = pin['pin1']
pin2 = pin['pin2']
pin3 = pin['pin3']
pin4 = pin['pin4']

pinx = [pin1, pin2, pin3, pin4]

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(pinx, GPIO.OUT)

GPIO.output(pinx, 1)
