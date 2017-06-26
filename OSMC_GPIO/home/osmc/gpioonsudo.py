#!/usr/bin/python

# need root access to /dev/mem
# gpioon.py cannot run sudo by itself

import os
#import xbmc

os.system('/usr/bin/sudo /home/osmc/gpioon.py &> /dev/null &')
