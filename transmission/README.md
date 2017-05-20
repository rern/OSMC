OSMC Transmission
---
Command line install  


[**Transmission**](https://transmissionbt.com/) - Fast, easy, and free BitTorrent client (CLI tools, daemon and web client)  

**Install**  
Connect a hard drive with label `hdd` or mount as `/media/hdd/`  
```sh
sudo su
wget -q --show-progress -O install.sh "https://github.com/rern/OSMC/blob/master/transmission/install.sh?raw=1"; chmod +x install.sh; ./install.sh
```

**Uninstall**  
```sh
sudo ./uninstall_tran.sh
```

**Start transmission**  
warning! - run as `root`
```sh
sudo systemctl start transmission-daemon
```

**Stop transmission**  
```sh
sudo systemctl stop transmission-daemon
```

**WebUI**    
Browser URL:  
_[RuneAudio IP]_:9091 (eg: 192.168.1.11:9091)  

**auto start download**  
add torrent files to `/media/hdd/transmission/torrents` will auto start download  

[optional] **set specific client IP**  
allow only IP
nolimit > `"rpc-whitelist-enabled": false`
```sh
    ....
    "rpc-whitelist": "127.0.0.1,[IP1],[IP2]",
    "rpc-whitelist-enabled": true,
    ...
```

**fix failed set buffer**  
... UDP Failed to set receive buffer:...
```sh
echo 'net.core.rmem_max=4194304
net.core.wmem_max=1048576
' >> /etc/sysctl.conf
systemctl stop transmission
sysctl -p
systemctl start transmission
