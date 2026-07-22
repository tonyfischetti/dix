# dix — Tony's debian machine configuration.  Single source of truth
# for wiring a debian desktop (replaces basic-install.sh).
#
#   make setup     idempotent: X dotfiles, app configs, systemd units
#                  (linked, not enabled — see below)
#   make doctor    check the install and report, loud + colorful
#
# Everything is re-runnable (`ln -sfn` + `mkdir -p`; the old bare
# `ln -s` died on the second run).  Linux-only: the whole repo
# configures debian desktops, so targets refuse politely on macOS.
#
# Units are LINKED by setup but enabling stays a deliberate act:
#   systemctl --user enable --now <unit>
# (doctor reports each unit's enabled-state so drift is visible.)
#
# The rest of the repo (etc/, kernels/, pkg-lists/, installation/) is
# records and system-level snapshots, applied by hand — not setup's
# business.

SHELL := /bin/bash

DIX     := $(CURDIR)
UNAME_S := $(shell uname -s)

UNITS := starlight.service skippy.service hotcorners.service custom-keys.service

.PHONY: help setup links units doctor

help:
	@echo "dix setup — targets:"
	@echo "  make setup     idempotent install (X dotfiles, app configs, units)"
	@echo "  make doctor    check the install and report"

ifeq ($(UNAME_S),Darwin)
setup links units:
	@echo "dix configures debian machines — nothing to do on macOS"
doctor:
	@echo "dix configures debian machines — nothing to check on macOS"
else

setup: links units
	@echo "setup complete — run 'make doctor' to verify."

links:
	ln -sfn $(DIX)/XCompose  $(HOME)/.XCompose
	ln -sfn $(DIX)/Xmodmap   $(HOME)/.Xmodmap
	ln -sfn $(DIX)/xinitrc   $(HOME)/.xinitrc
	ln -sfn $(DIX)/gtkrc-2.0 $(HOME)/.gtkrc-2.0
	ln -sfn $(DIX)/face      $(HOME)/.face
	mkdir -p $(HOME)/.config
	ln -sfn $(DIX)/dot-config/libinput-gestures.conf $(HOME)/.config/libinput-gestures.conf
	mkdir -p $(HOME)/.config/cava
	ln -sfn $(DIX)/dot-config/cava-config $(HOME)/.config/cava/config
	mkdir -p $(HOME)/.config/vlc
	ln -sfn $(DIX)/dot-config/vlcrc $(HOME)/.config/vlc/vlcrc
	mkdir -p $(HOME)/.config/skippy-xd
	ln -sfn $(DIX)/dot-config/skippy-xd.rc $(HOME)/.config/skippy-xd/skippy-xd.rc
	mkdir -p $(HOME)/.config/bl-hotcorners
	ln -sfn $(DIX)/dot-config/bl-hotcornersrc $(HOME)/.config/bl-hotcorners/bl-hotcornersrc
	mkdir -p $(HOME)/.config/xfce4/terminal
	ln -sfn $(DIX)/dot-config/xfce4_terminal_terminalrc $(HOME)/.config/xfce4/terminal/terminalrc

units:
	mkdir -p $(HOME)/.config/systemd/user
	for u in $(UNITS); do \
	  ln -sfn $(DIX)/units/$$u $(HOME)/.config/systemd/user/$$u; \
	done
	@if command -v systemctl >/dev/null && systemctl --user daemon-reload 2>/dev/null; then \
	  echo "units linked + daemon reloaded (enable deliberately: systemctl --user enable --now <unit>)"; \
	else \
	  echo "units linked (no systemd user session here — enable on the real machine)"; \
	fi

doctor:
	@bash $(DIX)/doctor.sh

endif
