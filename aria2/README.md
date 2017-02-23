OSMC aria2 with webui
---

[**aria2**](https://aria2.github.io/) - Download utility that supports HTTP(S), FTP, BitTorrent, and Metalink  
[**webui-aria2**](https://github.com/ziahamza/webui-aria2) - Web inferface for aria2  


**Install**  
```sh
wget -q --show-progress -O install.sh "https://github.com/rern/OSMC/blob/master/aria2/install.sh?raw=1"; chmod +x install.sh; ./install.sh
```

**Start aria2**  
```sh
aria2c
```

**WebUI**  
  
Browser URL:  
\[OSMC IP]:88  

Specify saved filename: (set directory in `dir` option)  
[download link] --out=[filename]  

**Stop aria2**  
```sh
pkill aria2c
```

**Uninstall**  
```sh
wget -q --show-progress -O uninstall.sh "https://github.com/rern/OSMC/blob/master/aria2/uninstall.sh?raw=1"; chmod +x uninstall.sh; ./uninstall.sh
```
