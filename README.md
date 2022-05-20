dix
===

A place to update and store my debian configuration (kernel config y lo que sea)

```
git clone https://github.com/tonyfischetti/dix.git ~/.dix
cd ~/.dix
./basic-install.sh
```


The units...

```
ln -s /home/tony/.dix/units/starlight.service /home/tony/.config/systemd/user/starlight.service
systemctl --user enable starlight.service
```

---

## miscellaneous

    - `DefaultTimeoutStopSec=30s` in /etc/systemd/user.conf
    - Mess with `/usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy`
    - Remove some cron stuff
    - Oh, and the GhostIt firefox extension hotkey now has to be "AltGraph"
    - Read installation notes



