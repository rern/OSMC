OSMC Aria2 with WebUI
---

[**aria2**](https://aria2.github.io/) - Download utility that supports HTTP(S), FTP, BitTorrent, and Metalink  
[**webui-aria2**](https://github.com/ziahamza/webui-aria2) - Web inferface for aria2  


**Install**  
Connect a hard drive with label `hdd` or mount as `/media/hdd/`  
```sh
sudo su
wget -q --show-progress -O install.sh "https://github.com/rern/OSMC/blob/master/aria2/install.sh?raw=1"; chmod +x install.sh; ./install.sh
```

**Uninstall**  
```sh
sudo ./uninstall.sh
```

**Start aria2**  
```sh
sudo systemctl start aria2
```

**Stop aria2**  
```sh
sudo systemctl stop aria2
```

**WebUI**  
Browser URL:  
_[OSMC IP]_:88 ( eg: 192.168.1.11:88 )  

Specify saved filename.ext - without spaces: (set directory in `dir` option)  
[download link] --out=[filename.ext]  
