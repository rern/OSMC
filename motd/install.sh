#!/bin/bash

rm $0

wget -qN --show-progress https://github.com/rern/title_script/raw/master/title.sh; . title.sh; rm title.sh

if [[ -e /usr/local/bin/uninstall_motd.sh ]]; then
  echo -e "$info OSMC logo motd already installed."
  exit
fi

title -l = "$bar Install OSMC logo motd ..."
wgetnc https://github.com/rern/OSMC/raw/master/motd/uninstall_motd.sh -P /usr/local/bin
chmod +x /usr/local/bin/uninstall_motd.sh

echo -e "$bar Modify files ..."

echo "
               ,:x0XNlNX0x:,             
           .oONWKOfffffffOKWNOo.         
       .lKWO:'              ':0WKl.      
     .xWK:                      :KWx.    
    lWK;                          :XNc   
   OMx       ;              ;       kMk  
  kMo        OXl         .oNk        dMx 
 cMO         OMWNl     .oWWMk         0M:
 KM,         OM::XNo..dWK::Mk         ;MO
 WW.         OM:  :NWWK:  :Mk         .MN
 WW.         OM: .dWX:    :Mk         .MN
 0M;         OMldWK:      :Mk         :MO
 :M0         OMMX:        :Mk         KM;
  xMx        OK:          :Q:        kMd 
   xMk       '                     .OMd  
    :NX:                          cNN:   
     .oWXl.                    .oNNo     
        cOWKd;.            .:dXWO:       
           .oONWKOxooooxOKWNOo.          
               ':x0XNNX0x:'               
 " > /etc/motd.logo

mv /etc/motd{,.original}

echo '#!/bin/bash

color=33

echo -e "\e[38;5;${color}m$( < /etc/motd.logo )\e[0m"
'> /etc/profile.d/motd.sh

sed -i -e '/^PS1=/ s/^/#/
' -e '/PS1=/ a\
color=242\
PS1=\x27\\[\\e[38;5;\x27$color\x27m\\]\\u@\\h:\\[\\e[0m\\]\\w \\$ \x27
' /etc/bash.bashrc
# PS1='\[\e[38;5;'$color'm\]\u@\h:\[\e[0m\]\w \$ '
# \x27       - escaped <'>
# \\         - escaped <\>
# \[ \]      - omit charater count when press <home>, <end> key
# \e[38;5;Nm - color
# \e[0m      - reset color
# \u         - username
# \h         - hostname
# \w         - current directory
# \$         - promt symbol: <$> users; <#> root

title -l = "$bar OSMC logo motd installed successfully."
echo -e "\nUninstall: uninstall_motd.sh"
title -nt "$info Relogin to see new OSMC logo motd."
