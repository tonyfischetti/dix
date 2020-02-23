#!/bin/bash

# add this to the xfce session autostart executing "sh /home/tony/.dix/startup.sh"

THEHOST=`hostname`

# if [ $THEHOST == "qonos" ] ; then
#     synclient VertScrollDelta=-73
#     # another non-working option
#     xinput --set-int-prop 12 "libinput Natural Scrolling Enabled" 8 1 
# fi

sh ~/starlight/start-starlight.sh
