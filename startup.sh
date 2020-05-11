#!/bin/bash

# add this to the xfce session autostart executing "sh /home/tony/.dix/startup.sh"

# STARTLIGHT IS NOW MANAGED BY SYSTEMD
# sh ~/starlight/start-starlight.sh

touch "/home/tony/Desktop/opened"
THEHOST=`hostname`

if [ $THEHOST == "qonos" ] ; then
    xinput --set-int-prop 13 "libinput Natural Scrolling Enabled" 8 1
    xinput --set-int-prop 13 "libinput Tapping Enabled" 8 1
fi

exit 0

