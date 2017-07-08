**Addons install script** for `script.skinshortcuts`  

- download > extract to `/home/osmc/.kodi/addons`
- check depends in `./script.skinshortcuts/addon.xml` field `<requires>`
- download the required addons > extract to `/home/osmc/.kodi/addons`
- check each new `addon.xml` for other `<requires>`
- add addons to database
- enable each addon in database
- update addons database
- reload skin

```sh
kodipath=/home/osmc/.kodi/userdata
addonpath=/home/osmc/.kodi/addons
pkgpath=$addonpath/packages
dbpath=$kodipath/Database
# for 'unzip'
apt install -y bsdtar
# download addon and 'requires'
wget -qN --show-progress https://github.com/BigNoid/script.skinshortcuts/archive/master.zip -O $pkgpath/script.skinshortcuts.zip
wget -qN --show-progress https://github.com/XBMC-Addons/script.module.simplejson/archive/master.zip -O $pkgpath/script.module.simplejson.zip
wget -qN --show-progress http://mirrors.kodi.tv/addons/jarvis/script.module.unidecode/script.module.unidecode-0.4.16.zip -O $pkgpath/script.module.unidecode.zip
# extract
bsdtar -xf $pkgpath/script.skinshortcuts.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.simplejson.zip -C $addonpath
bsdtar -xf $pkgpath/script.module.unidecode.zip -C $addonpath
chown -R osmc:osmc $addonpath
# add addons to database
xbmc-send -a "UpdateLocalAddons()"
sleep 2
# enable addons in database
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.simplejson'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.module.unidecode'"
sqlite3 $dbpath/Addons27.db "UPDATE installed SET enabled = 1 WHERE addonID = 'script.skinshortcuts'"
# update addons database
xbmc-send -a "UpdateLocalAddons()"
sleep 2
# force reload skin
xbmc-send -a "ReloadSkin()"
```
