#!/usr/bin/python

# need root access to /dev/mem, /sys/module
# this script cannot run sudo by itself
import gpiooff
import os
import sys
	
if len(sys.argv) == 1: # no argument
	os.system('/usr/bin/xbmc-send -a "Powerdown"')
else: # with any argument
	os.system('/usr/bin/xbmc-send -a "Reboot"')
