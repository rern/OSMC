**Compile VNC**
```sh
apt install build-essential rbp-userland-dev-osmc libvncserver-dev libconfig++-dev unzip
wget https://github.com/patrikolausson/dispmanx_vnc/archive/master.zip
unzip master.zip -d  /home/osmc/
rm master.zip
/home/osmc/dispmanx_vnc-master/make
ln -s /home/osmc/dispmanx_vnc-master/dispmanx_vncserver /usr/bin/vnc
```

**Start VNC server**
```sh
vnc
```
 **Connect from PC**  
 Install [TightVNC](http://www.tightvnc.com/)
 
