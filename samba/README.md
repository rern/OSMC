Samba
---

OSMC Samba  

**Install**  
```sh
apt install samba
```

**/etc/samba/smb.conf**
```sh
[global]
	netbios name = [name]
	workgroup = WORKGROUP
	server string = Samba %v on %L
	encrypt passwords = yes
	wins support = yes
	domain master = yes
	preferred master = yes
	local master = yes
	os level = 255   
	dns proxy = no
	log level = 0
	syslog = 0

	guest ok = yes
	null passwords = yes
	map to guest = bad user

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

**Restart samba**
```sh
systemctl restart smbd

# if set new hostname
systemctl restart nmbd
```

**Add samba user + password**
```sh
smbpasswd -a [user]
```

**Set hostname** (If `netbios name` in `smb.conf` not work.)  
Shows in file browser
```sh
hostnamectl set-hostname [name]
```
