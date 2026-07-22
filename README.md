dix
===

A place to update and store my debian configuration (kernel config y lo que sea)

```
git clone https://github.com/tonyfischetti/dix.git ~/.dix
make -C ~/.dix setup     # X dotfiles, app configs, systemd units (linked)
make -C ~/.dix doctor    # verify everything
```

The Makefile is the single source of truth (it replaced
`basic-install.sh`).  Everything is idempotent, and linux-only (it
refuses politely on macOS).  `setup` links the units into
`~/.config/systemd/user/` but enabling stays a deliberate act:

```
systemctl --user enable --now starlight.service
```

`make doctor` reports each unit's enabled-state, so drift is visible.

---

## miscellaneous

    - `DefaultTimeoutStopSec=30s` in /etc/systemd/user.conf
    - Mess with `/usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy`
    - Remove some cron stuff
    - Oh, and the GhostIt firefox extension hotkey now has to be "AltGraph"
    - Read installation notes



