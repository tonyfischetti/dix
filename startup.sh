#!/bin/bash

set -euxo pipefail

# add this to the xfce session autostart executing "sh /home/tony/.dix/startup.sh"

# STARTLIGHT IS NOW MANAGED BY SYSTEMD
# sh ~/starlight/start-starlight.sh


echo "setting custom xmodmap"
/usr/bin/xmodmap /home/tony/.Xmodmap

THEHOST=`hostname`

if [ $THEHOST == "qonos" ] ; then
    echo "setting up qonos-specific touchpad things"
    xinput --set-int-prop 13 "libinput Natural Scrolling Enabled" 8 1
    xinput --set-int-prop 13 "libinput Tapping Enabled" 8 1
fi


