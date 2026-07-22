#!/usr/bin/env bash
# dix doctor — check that this debian machine's configuration is
# properly wired.  Reports, never mutates, exits nonzero if something
# is wrong.  Invoked by `make doctor` (linux-only).

DIX="$(cd "$(dirname "$0")" && pwd)"

green="\033[32m"; red="\033[31m"; yellow="\033[33m"; bold="\033[1m"; off="\033[0m"
fail=0
ok()   { printf "  ${green}✓${off} %s\n" "$1"; }
bad()  { printf "  ${red}✗ %s${off}\n" "$1"; fail=1; }
warn() { printf "  ${yellow}! %s${off}\n" "$1"; }

printf "${bold}dix doctor${off} (%s)\n" "$(uname -s)"

# --- dotfile / config links ---
links="
$HOME/.XCompose|XCompose
$HOME/.Xmodmap|Xmodmap
$HOME/.xinitrc|xinitrc
$HOME/.gtkrc-2.0|gtkrc-2.0
$HOME/.face|face
$HOME/.config/libinput-gestures.conf|dot-config/libinput-gestures.conf
$HOME/.config/cava/config|dot-config/cava-config
$HOME/.config/vlc/vlcrc|dot-config/vlcrc
$HOME/.config/skippy-xd/skippy-xd.rc|dot-config/skippy-xd.rc
$HOME/.config/bl-hotcorners/bl-hotcornersrc|dot-config/bl-hotcornersrc
$HOME/.config/xfce4/terminal/terminalrc|dot-config/xfce4_terminal_terminalrc
"
linkfail=0
while IFS='|' read -r link src; do
  [ -z "$link" ] && continue
  if ! [ "$link" -ef "$DIX/$src" ]; then
    bad "$link does not resolve to dix's $src (make setup)"
    linkfail=1
  fi
done <<< "$links"
[ "$linkfail" -eq 0 ] && ok "all dotfile/config symlinks resolve into $DIX"

# --- systemd user units: linked, and report enabled-state ---
for u in starlight.service skippy.service hotcorners.service custom-keys.service; do
  if [ "$HOME/.config/systemd/user/$u" -ef "$DIX/units/$u" ]; then
    if command -v systemctl >/dev/null; then
      state="$(systemctl --user is-enabled "$u" 2>/dev/null)"
      case "$state" in
        enabled) ok "$u linked + enabled" ;;
        "")      warn "$u linked (no systemd user session to query)" ;;
        *)       warn "$u linked but $state (systemctl --user enable --now $u)" ;;
      esac
    else
      warn "$u linked (systemctl unavailable)"
    fi
  else
    bad "$u not linked into ~/.config/systemd/user (make setup)"
  fi
done

# --- the apps these configs configure (warn tier) ---
for t in cava vlc skippy-xd libinput-gestures xfce4-terminal; do
  command -v "$t" >/dev/null || warn "$t not installed (its config is linked but unused)"
done

echo
if [ "$fail" -eq 0 ]; then
  printf "${green}${bold}all good.${off}\n"
else
  printf "${red}${bold}problems found — see above.${off}\n"
fi
exit "$fail"
