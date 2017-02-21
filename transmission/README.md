OSMC transmission
---
Command line install  


[**Transmission**](https://transmissionbt.com/) - Fast, easy, and free BitTorrent client (CLI tools, daemon and web client)  

**Install**  
```sh
sudo su
apt-get install transmission-daemon transmission-cli
```

**Stop transmission**  
```sh
systemctl stop transmission
```

**Create directories, set owner**
```sh
mkdir /media/hdd/transmission
mkdir /media/hdd/transmission/incomplete
mkdir /media/hdd/transmission/torrents
chown -R osmc:osmc /media/hdd/transmission
```

**/etc/transmission-daemon/settings.json** - edit:  
_if install from OSMC App Store: /home/osmc/.config/transmission-daemon/settings.json_
set directories  
```sh
    ...
    "download-dir": "/media/hdd/transmission",
    "incomplete-dir": "/media/hdd/transmission/incomplete",
    "incomplete-dir-enabled": true,
    ...
```
[optional] set login  
- plain text `"rpc-password"` will be hash once login
- logout > close browser (no explicit logout, close tab not logout)
- no login > `"rpc-authentication-required": false`  
```sh
    ...
    "rpc-authentication-required": true,
    ...
    "rpc-password": "osmc",
    ...
    "rpc-username": "osmc",
    ....
```
[optional] set specific client IP  
- allow only IP
- nolimit > `"rpc-whitelist-enabled": false`
```sh
    ....
    "rpc-whitelist": "127.0.0.1,[IP1],[IP2]",
    "rpc-whitelist-enabled": true,
    ...
```
set auto start download  
- add torrent files to `watch-dir` will auto start download  
- appending to last line needs a comma in the line before
```sh
    ...
    "watch-dir": "/media/hdd/transmission/torrents",
    "watch-dir-enabled": true
```

**Start transmission**  
```sh
systemctl start transmission
```

**Disable auto start transmission on system start**  
```sh
systemctl disable transmission
```

**WebUI**  
  
Browser URL:  
  
_RuneAudio IP_:9091 (eg: 192.168.1.11:9091)  
