#!/usr/bin/python

# need root access to /dev/mem
# gpioon.py cannot run sudo by itself
# kodi has trouble with 'RunScript(*.sh)' - use *.py instead

import os
#import xbmc

os.system('/usr/bin/sudo /home/osmc/gpioon.py')
