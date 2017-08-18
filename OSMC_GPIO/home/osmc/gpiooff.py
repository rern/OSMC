#!/usr/bin/python
from gpio import *
import os
import sys

if GPIO.input(offx[1]) == 1:
	if len(sys.argv) == 1: # bypass on shutdown/reboot (with any argument) 
		os.system('/usr/bin/xbmc-send -a "Notification(GPIO,Already OFF)"')

else:
	import time

	if off1 != 0:
		GPIO.output(off1, 1)
	if off2 != 0:
		time.sleep(offd1)
		GPIO.output(off2, 1)
	if off3 != 0:
		time.sleep(offd2)
		GPIO.output(off3, 1)
	if off4 != 0:
		time.sleep(offd3)
		GPIO.output(off4, 1)
	
	os.system('/usr/bin/sudo /usr/bin/pkill -9 gpiotimer.py &')
