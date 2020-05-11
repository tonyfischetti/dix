dix
===

A place to update and store my debian configuration (kernel config y lo que sea)

    git clone https://github.com/tonyfischetti/dix.git ~/.dix
    ln -s ~/.dix/XCompose ~/.XCompose
    ln -s ~/.dix/Xmodmap ~/.Xmodmap
    ln -s ~/.dix/xinitrc ~/.xinitrc
    ln -s ~/.dix/face ~/.face
    ln -s ~/.dix/dot-config/libinput-gestures.conf ~/.config/libinput-gestures.conf
    ln -s /home/tony/.dix/units/starlight.service /home/tony/.config/systemd/user/starlight.service
    systemctl --user enable starlight.service

