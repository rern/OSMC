**Install `script.skinshortcuts` with command line**  

- download > extract to `/home/osmc/.kodi/addons`
- check depends in `./script.skinshortcuts/addon.xml` field `<requires>`
- download the required addons > extract to `/home/osmc/.kodi/addons`
- check each new `addon.xml` for other `<requires>`
- update addons database (add rows)
- enable each addon in each row
- reload skin

```sh
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database

apt install -y bsdtar

wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip -O $pkgpath/script.skinshortcuts.zip
wget -qN --show-progress https://github.com/XBMC-Addons/script.module.simplejson/archive/master.zip -O $pkgpath/script.module.simplejson.zip
wget -qN --show-progress http://mirrors.kodi.tv/addons/jarvis/script.module.unidecode/script.module.unidecode-0.4.16.zip -O $pkgpath/script.module.unidecode.zip

bsdtar -xf $pkgpath/script.skinshortcuts.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.simplejson.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.unidecode.zip -C $addonpath
chown -R osmc:osmc $addonpath

xbmc-send -a "UpdateLocalAddons()"

sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.simplejson'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.unidecode'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.skinshortcuts'"

xbmc-send -a "ReloadSkin()"
```
