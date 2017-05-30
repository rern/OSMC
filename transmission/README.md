OSMC Transmission
---

[**Transmission**](https://transmissionbt.com/) - Fast, easy, and free BitTorrent client (CLI tools, daemon and web client)  
- With optional WebUI alternative: [Transmission Web Control](https://github.com/ronggang/transmission-web-control#introduction)  

**Install**  
Connect a hard drive with label `hdd` or mount as `/media/hdd/`  
```sh
sudo su
wget -qN --show-progress https://github.com/rern/OSMC/raw/master/transmission/install.sh; chmod +x install.sh; ./install.sh
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
