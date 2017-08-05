#!/usr/bin/python

# need root access to /dev/mem
# gpiooff.py cannot run sudo by itself
# kodi has trouble with 'RunScript(*.sh)' - use *.py instead

import os
import sys
#import xbmc

ar = 'r' if len(sys.argv) > 1 else ''
os.system('/usr/bin/sudo /home/osmc/gpiooff.py '+ ar)
