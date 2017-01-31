#!/usr/bin/python

# need root access to /dev/mem, /sys/module
# this script cannot run sudo by itself

import os

os.system('/home/osmc/gpiooff.py 0')
os.system('/usr/bin/xbmc-send -a "Powerdown"')
