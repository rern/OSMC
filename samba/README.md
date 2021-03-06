Samba
---

OSMC Samba  

**Install**  
```sh
sudo su
apt update
apt install samba
```

**Server name**  
- any os file browsers:
```sh
hostnamectl set-hostname [name]
```
- only Windows(NetBIOS) file browsers:  
`netbios name` in `/etc/samba/smb.conf`  

**/etc/samba/smb.conf**
```sh
[global]
#	netbios name = [name]
	workgroup = WORKGROUP
	server string = Samba %v on %L
	
	wins support = yes
	domain master = yes
	preferred master = yes
	local master = yes
	os level = 255   
	dns proxy = no
	log level = 0

	socket options = IPTOS_LOWDELAY TCP_NODELAY SO_RCVBUF=131072 SO_SNDBUF=131072
	min receivefile size = 16384
	use sendfile = yes
	aio read size = 2048
	aio write size = 2048
	write cache size = 1024000
	read raw = yes
	write raw = yes
	getwd cache = yes
	oplocks = yes
	max xmit = 32768
	dead time = 15
	large readwrite = yes
	unix extensions = no
	strict locking = no

	guest ok = yes
	map to guest = bad user
	encrypt passwords = yes

	load printers = no
	printing = bsd
	printcap name = /dev/null
	disable spoolss = yes

[readwrite]
	comment = browseable, read, write, guess ok, no password
	path = /media/hdd/readwrite
	read only = no
[read]
	comment = browseable, read only, guess ok, no password
	path = /media/hdd/read
[root]
	comment = hidden, read, write, root with password only, from [IP1] [IP2] only
	path = /media/root
	browseable = no
	read only = no
	guest ok = no
	valid users = root
#	host allow = [IP1] [IP2]
```

**Restart**
```sh
systemctl restart smbd nmbd
```

**Test conf parameters**
```
testparm
```

**Add user + password**
```sh
adduser [user] # create new system user if not exist
smbpasswd -a [user]
```

**List accessing**  
`smbstatus`  
