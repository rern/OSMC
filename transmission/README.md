RuneAudio_transmission
---

[**Transmission**](https://transmissionbt.com/) - Fast, easy, and free BitTorrent client (CLI tools, daemon and web client)  

**Install**  
```sh
sudo su
apt-get install transmission-daemon transmission-cli
```

**Config**  
```sh
systemctl stop transmission
```

**/etc/transmission-daemon/settings.json** - edit:  
- plain text `password` will be hash once login
- logout > close browser (no explicit logout, close tab not logout)
- no password > "rpc-authentication-required": false  
```sh
    "download-dir": "/[path]/transmission",
    "incomplete-dir": "/[path]/transmission/.incomplete",
    "incomplete-dir-enabled": true,
    
    "rpc-authentication-required": true,
    "rpc-password": "[password]",
    "rpc-username": "[username]",
    
    "rpc-whitelist-enabled": false,
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
