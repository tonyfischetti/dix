dix
===

A place to update and store my debian configuration (kernel config y lo que sea)

    git clone https://github.com/tonyfischetti/dix.git ~/.dix
    ln -s ~/.dix/XCompose ~/.XCompose
    ln -s ~/.dix/Xmodmap ~/.Xmodmap
    ln -s ~/.dix/xinitrc ~/.xinitrc
    ln -s ~/.dix/gtkrc-2.0 ~/.gtkrc-2.0
    ln -s ~/.dix/face ~/.face
    ln -s ~/.dix/dot-config/libinput-gestures.conf ~/.config/libinput-gestures.conf
    ln -s ~/.dix/dot-config/cava-config ~/.config/cava/config
    ln -s ~/.dix/dot-config/vlcrc ~/.config/vlc/vlcrc
    ln -s ~/.dix/dot-config/skippy-xd.rc ~/.config/skippy-xd/skippy-xd.rc
    ln -s ~/.dix/dot-config/bl-hotcornersrc  ~/.config/bl-hotcorners/bl-hotcornersrc
    ln -s ~/.dix/dot-config/xfce4_terminal_terminalrc ~/.config/xfce4/terminal/terminalrc

The units...

    ln -s /home/tony/.dix/units/starlight.service /home/tony/.config/systemd/user/starlight.service
    systemctl --user enable starlight.service
    ...

---

## miscellaneous

    - `DefaultTimeoutStopSec=30s` in /etc/systemd/user.conf
    - Mess with `/usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy`
    - Remove some cron stuff
    - Oh, and the GhostIt firefox extension hotkey now has to be "AltGraph"
    - Read installation notes


