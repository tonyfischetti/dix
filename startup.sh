#!/bin/bash

# add this to the xfce session autostart executing "sh /home/tony/.dix/startup.sh"

THEHOST=`hostname`

if [ $THEHOST == "qonos" ] ; then
    xinput --set-int-prop 13 "libinput Natural Scrolling Enabled" 8 1
    xinput --set-int-prop 13 "libinput Tapping Enabled" 8 1
fi

sh ~/starlight/start-starlight.sh
