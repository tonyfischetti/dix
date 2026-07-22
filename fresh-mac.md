# Fresh mac setup

The debian story lives in `docker/risa/Dockerfile`; this is the mac
equivalent.  Same architecture: each `*ix` repo owns its own setup via
an idempotent Makefile (`deps` / `setup` / `doctor`), and every doctor
exits nonzero when something's broken — so run them and believe them.

## 0. the manual layer (nothing owns these)

1. **Xcode Command Line Tools** — provides git, make, clang:

       xcode-select --install

2. **Homebrew** — https://brew.sh — every `make deps` assumes it.
   (NB: the repos assume apple silicon — brew at `/opt/homebrew`.
   clix's libstyx build hardcodes `/opt/homebrew/opt/openssl@3`.)

3. **R** — the CRAN framework build: https://cran.r-project.org/bin/macosx/
   (rix's `deps` checks for it but won't install it)

4. **bun** — https://bun.sh — for zix's `bin/codex`
   (zix pins it from release zips on linux; on mac install it yourself)

5. **node** — `brew install node` (or the nodesource of your choosing);
   vix's npm neovim provider and zix's npm bits want it, everything
   degrades gracefully without it

## 1. the repos, in dependency-friendly order

    git clone https://github.com/tonyfischetti/zix.git ~/.zsh
    make -C ~/.zsh deps && make -C ~/.zsh setup && make -C ~/.zsh doctor

    git clone https://github.com/tonyfischetti/rix.git ~/.rix
    make -C ~/.rix deps && make -C ~/.rix setup && make -C ~/.rix doctor

    mkdir -p ~/.config
    git clone https://github.com/tonyfischetti/vix.git ~/.config/nvim
    make -C ~/.config/nvim deps && make -C ~/.config/nvim setup && make -C ~/.config/nvim doctor

    git clone https://github.com/tonyfischetti/clix.git ~/.lisp
    make -C ~/.lisp deps && make -C ~/.lisp setup && make -C ~/.lisp doctor

    git clone https://github.com/tonyfischetti/tmix.git ~/.tmux
    make -C ~/.tmux deps && make -C ~/.tmux setup && make -C ~/.tmux doctor

(zix first so `~/.zsh/bin` — lispscript et al. — is in place for
clix's doctor; clix's `make setup` clones pluto itself.  dix stays off
the list: it configures debian desktops and refuses politely on macOS.)

## 2. known rough edges on a cold mac

- **tmix is the untested path**: with no `/usr/local/bin/tmux`,
  `setup` really builds the patched tmux 2.6, and 2017 C under a
  modern clang may need coaxing.  If it fails, bring the error to a
  session and soften CFLAGS in tmix's `make tmux` recipe.
- **intel macs**: brew lives at `/usr/local` there, so the
  `/opt/homebrew` assumptions (libstyx's openssl path, PATH ordering)
  need adjusting.
- Log in to things (gh, Dropbox, pass/gpg keys) before expecting the
  scripts that lean on them to work.

## 3. verify everything at once

    for d in ~/.zsh ~/.rix ~/.config/nvim ~/.lisp ~/.tmux; do
      make -C "$d" doctor || echo "^^^ $d"
    done

and the real acceptance test:

    make -C ~/pluto test
