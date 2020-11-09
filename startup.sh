#!/bin/bash

set -euxo pipefail


echo "setting custom xmodmap" | systemd-cat -t miscellaneous
/usr/bin/xmodmap /home/tony/.Xmodmap
echo "successful" | systemd-cat -t miscellaneous

THEHOST=`hostname`

if [ $THEHOST == "qonos" ] ; then
    echo "setting up qonos-specific touchpad things" | systemd-cat -t miscellaneous
    WHICHONE=`xinput | egrep 'ELAN.+Touchpad' | perl -pe 's/.+id=(\d+).+/$1/'`
    echo "choosing xinput $WHICHONE" | systemd-cat -t miscellaneous
    xinput --set-int-prop $WHICHONE "libinput Natural Scrolling Enabled" 8 1
    xinput --set-int-prop $WHICHONE "libinput Tapping Enabled" 8 1
    echo "successful" | systemd-cat -t miscellaneous
fi


