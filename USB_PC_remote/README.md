ID 1d57:ad02 Xenta SE340D PC Remote Control  
(Tested on RPi 3)

For less than $4, free shipping from ebay, this remote set was detected and can be used as a keyboard and a mouse.  

- Use in Kodi without any settings. (no more CEC hassels)
- Use as a keyboard to select an OS in NOOBS boot menu.

![remote](https://github.com/rern/Assets/blob/master/OSMC_GPIO/usb_pc_remote_button_code.jpg)  

**How to customize with keymaps:**  
- Create the following code file
- Edit mapping as you like. (use either 'key name' or 'key id')
- Restart (Power > Exit) once to load the file. 
- Then on finish editing, just press the green button to 'ReloadKeymaps' without restart.

**/root/osmc/.kodi/userdata/keymaps/keyboard.xml**
```sh
<?xml version="1.0" encoding="UTF-8"?>
<!-- ### custom keymaps for 'ID 1d57:ad02 Xenta SE340D PC Remote Control' ### -->
<!--
<tab>		SystemInfo <-> Back | FullscreenInfo <-> Back
<open>		MovieTitles | MovieTitle <-> Fullscreen
<switchwindow>	Settings <-> Back | VideosSettings <-> Back
<blue>		NextSubtitle
<yellow>	AudioNextLanguage (next audio language)
<amber>		OSDAudioSettings
<green>		ReloadKeymaps (without restart)
-->
<keymap>
  <global>
    <keyboard>
      <!-- e-mail --><launch_mail><launch_mail>
      <!-- www --><homepage></homepage>
      <!-- close --><f4 mod="alt"></f4>
      <!-- yellow --><d mod="ctrl,alt"></d>
      <!-- blue --><c mod="ctrl,alt"></c>
      <!-- amber --><b mod="ctrl,alt"></b>
      <!-- green --><a mod="ctrl,alt">reloadkeymaps</a>
      <!-- tab --><tab>ActivateWindow(SystemInfo)</tab>
      <!-- start --><key id="2159104"></key>
      <!-- open --><o mod="ctrl">ActivateWindow(Videos,MovieTitles)</o>
      <!-- esc --><escape></escape>
      <!-- switchwindow --><key id="323593">ActivateWindow(Settings)</key>
    </keyboard>
  </global>
  <FullscreenVideo>
    <keyboard>
      <!-- yellow --><d mod="ctrl,alt">AudioNextLanguage</d>
      <!-- blue --><c mod="ctrl,alt">NextSubtitle</c>
      <!-- amber --><b mod="ctrl,alt"></b>
      <!-- green --><a mod="ctrl,alt">ActivateWindow(osdaudiosettings)</a>
      <!-- tab --><tab>ActivateWindow(fullscreeninfo)</tab>
      <!-- switchwindow --><key id="323593">ActivateWindow(VideosSettings)</key>
    </keyboard>
  </FullscreenVideo>
  <FullscreenInfo>
    <keyboard>
      <!-- tab --><tab>Back</tab>
    </keyboard>
  </FullscreenInfo>
  <MyVideoLibrary>
    <keyboard>
      <!-- open --><o mod="ctrl">Fullscreen</o>
    </keyboard>
  </MyVideoLibrary>
  <SystemInfo>
    <keyboard>
      <!-- tab --><tab>Back</tab>
    </keyboard>
  </SystemInfo>
  <Settings>
    <keyboard>
      <!-- switchwindow --><key id="323593">Back</key>
    </keyboard>
  </Settings>
  <VideosSettings>
    <keyboard>
      <!-- switchwindow --><key id="323593">Back</key>
    </keyboard>
  </VideosSettings>
</keymap>
```

If you want to a fully customizable remote, you need this:  
[JP1 Remote](http://www.hifi-remote.com/wiki/index.php?title=JP1_-_Just_How_Easy_Is_It%3F_-_RM-IR_Version) - The ultimate solution of a remote.  
It's like Raspberry Pi of ir remote world.
