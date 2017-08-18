#!/usr/bin/python
from gpio import *
import os

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
	
	os.system('/usr/bin/sudo /home/osmc/gpiotimer.py &')
