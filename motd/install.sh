#!/bin/bash

rm $0

if [[ -e /etc/motd.logo ]]; then
  echo -e '\n"OSMC logo motd" already installed.\n'
  exit
fi

wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh

gitpath=https://raw.githubusercontent.com/rern/OSMC/master/motd
title -l = "$bar Install OSMC logo motd ..."
wget -qN --show-progress $gitpath/uninstall_motd.sh; chmod +x uninstall_motd.sh
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

echo -e "\nUninstall: ./uninstall_motd.sh"
title -nt "$info Relogin to see new OSMC logo motd."
