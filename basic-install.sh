#!/bin/bash

set -euxo pipefail

# git clone https://github.com/tonyfischetti/dix.git ~/.dix
ln -s ~/.dix/XCompose ~/.XCompose
ln -s ~/.dix/Xmodmap ~/.Xmodmap
ln -s ~/.dix/xinitrc ~/.xinitrc
ln -s ~/.dix/gtkrc-2.0 ~/.gtkrc-2.0
ln -s ~/.dix/face ~/.face
mkdir -p ~/.config/
ln -s ~/.dix/dot-config/libinput-gestures.conf ~/.config/libinput-gestures.conf
mkdir -p ~/.config/cava
ln -s ~/.dix/dot-config/cava-config ~/.config/cava/config
mkdir -p ~/.config/vlc
ln -s ~/.dix/dot-config/vlcrc ~/.config/vlc/vlcrc
mkdir -p ~/.config/skippy-xd
ln -s ~/.dix/dot-config/skippy-xd.rc ~/.config/skippy-xd/skippy-xd.rc
mkdir -p ~/.config/bl-hotcorners
ln -s ~/.dix/dot-config/bl-hotcornersrc  ~/.config/bl-hotcorners/bl-hotcornersrc
mkdir -p ~/.config/xfce4/terminal
ln -s ~/.dix/dot-config/xfce4_terminal_terminalrc ~/.config/xfce4/terminal/terminalrc


