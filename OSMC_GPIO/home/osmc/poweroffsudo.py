#!/usr/bin/python

# need root access to /dev/mem, /sys/module
# bootosmc.py cannot run sudo by itself

import os
os.system('/usr/bin/sudo /home/osmc/poweroff.py')
