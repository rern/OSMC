#!/usr/bin/python

# need root access to /dev/mem
# gpiooff.py cannot run sudo by itself

import os
#import xbmc

os.system('/usr/bin/sudo /home/osmc/gpiooff.py > /dev/null 2>&1 &')
