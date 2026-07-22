# syntax=docker/dockerfile:1.3-labs

# Environment variable DOCKER_BUILDKIT must be set to "1"
# before building this image

# Section order is caching-deliberate: stable + expensive layers
# (the big apt monoliths) come first, the actively-developed repo
# sections come last (lisp above all), so iterative edits invalidate
# as little as possible.

FROM debian:trixie-slim

LABEL maintainer="tony.fischetti@gmail.com"

ENV TERM=screen-256color
ENV LANG=C.UTF-8
ENV SHELL=/usr/bin/zsh

ARG USERNAME=tony
ARG USER_UID=1000
ARG USER_GID=$USER_UID


COPY etc.motd /etc/motd
COPY etc.apt.sources.list /etc/apt/sources.list
RUN <<EOF
    rm /etc/apt/sources.list.d/debian.sources
EOF


# essential packages
RUN <<EOF
    apt-get update  -qq                                                 &&
    apt-get upgrade -qq                                                 &&
    apt-get install -qq -y git sudo wget curl make
EOF


# create non-root user
RUN <<EOF
    groupadd --gid $USER_GID $USERNAME &&
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME &&
    usermod -a $USERNAME -G sudo &&
    mkdir -p /etc/sudoers.d/ &&
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME &&
    chmod 0440 /etc/sudoers.d/$USERNAME
EOF

USER $USERNAME
WORKDIR /home/$USERNAME


# gpg fix
RUN <<EOF
    mkdir -p ~/.gnupg/tmp &&
    chown -R $(whoami) ~/.gnupg/ &&
    chmod 600 ~/.gnupg/* &&
    chmod 700 ~/.gnupg
EOF


# other languages
# (ecl moved to clix's deps; python3-neovim/ruby-neovim to vix's)
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y                                            \
      luarocks ruby gem clang golang                                       \
      default-jdk maven racket python3-pip rustup ghc cabal-install &&
    rustup default stable
EOF


# other packages
# general tools the shell + scripts assume exist.  NB: `ssh` also
# provides /etc/ssh/sshd_config, which the "configuration changes"
# section below edits — removing it breaks that section.  (The R
# build libs that used to hide in this list now live in rix's deps.)
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y                                            \
      apt-utils ack ripgrep htop sqlite3 ssh moreutils ffmpeg figlet ncdu  \
      suckless-tools pandoc pwgen parallel iotop imv renameutils fd-find   \
      libnotify-dev colordiff dos2unix gawk jpegoptim keyutils patchutils  \
      rsync acpi visidata jags libudunits2-dev libgdal-dev libsqlite3-dev  \
      pass gfortran less postgresql-client libfmt-dev libre2-dev           \
      libboost-dev libspdlog-dev debconf-utils
EOF


# install nodejs
RUN <<EOF
    curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh &&
    sudo -E bash nodesource_setup.sh &&
    sudo apt -qq -y install nodejs &&
    rm nodesource_setup.sh
EOF


# setup zsh
# zix's Makefile is the single source of truth, same shape as clix:
# `deps` owns the OS packages, `setup` is the idempotent install
# (symlinks, artifacts, node deps), `doctor` fails the build if
# anything is broken.
RUN <<EOF
    git clone https://github.com/tonyfischetti/zix.git $HOME/.zsh &&
    make -C $HOME/.zsh deps &&
    make -C $HOME/.zsh setup &&
    make -C $HOME/.zsh doctor &&
    sudo usermod -s /usr/bin/zsh $USERNAME
EOF


# setup r
RUN <<EOF
    git clone https://github.com/tonyfischetti/rix.git ~/.rix &&
    make -C ~/.rix deps &&
    make -C ~/.rix setup &&
    make -C ~/.rix doctor
EOF


# setup neovim
# vix's Makefile owns everything: `deps` installs the pinned nvim
# binary (arch auto-detected), tools, and providers (incl. the npm
# neovim module, best-effort — which is why it's no longer in the
# nodejs section above); `setup` restores plugins pinned to
# lazy-lock.json; `doctor` fails the build if anything — including a
# headless startup of the full config — is broken.
RUN <<EOF
    mkdir -p ~/.config &&
    git clone https://github.com/tonyfischetti/vix.git ~/.config/nvim &&
    make -C ~/.config/nvim deps &&
    make -C ~/.config/nvim setup &&
    make -C ~/.config/nvim doctor
EOF


# setup tmux
RUN <<EOF
    git clone https://github.com/tonyfischetti/tmix.git ~/.tmux &&
    make -C ~/.tmux deps &&
    make -C ~/.tmux setup &&
    make -C ~/.tmux doctor
EOF


# setup zpaq
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt build-dep -y --no-install-recommends zpaq &&
    git clone https://github.com/tonyfischetti/zpaq &&
    cd zpaq &&
    make &&
    sudo make install &&
    cd .. &&
    rm -rf zpaq
EOF


# setup cmus
# cmix's Makefile owns everything, same shape as tmix: `deps` is
# `apt build-dep cmus`, `setup` makes ~/music and builds the patched
# cmus (the fork's default branch) if missing, `doctor` fails the
# build if anything is broken.  The repo must live at ~/cmus
# (CMUS_HOME, exported by zix's .zshrc).  CONFIG_MPRIS=n because a
# container has no D-Bus session — with it compiled in, cmus nags
# "error while initializing MPRIS" at every launch.
RUN <<EOF
    git clone https://github.com/tonyfischetti/cmix.git ~/cmus &&
    make -C ~/cmus deps &&
    make -C ~/cmus setup CMUS_CONFIGURE_FLAGS="CONFIG_MPRIS=n" &&
    make -C ~/cmus doctor
EOF


# setup lisp
# clix's Makefile is the single source of truth: `deps` installs the OS
# packages (sbcl, ecl, smenu, gcc, libssl-dev, ...), `setup` is the
# idempotent bootstrap (quicklisp, rc links, pluto clone, libstyx,
# saved core), and `doctor` exits nonzero if anything is broken —
# failing the build here rather than at runtime.  (The scripts'
# #!/usr/bin/env lispscript shebangs resolve via PATH — ~/.zsh/bin —
# so no /usr/local/bin link.)
# Last of the repo sections on purpose: it's the most actively
# developed, so its cache invalidations should cost nothing else.
RUN <<EOF
    git clone https://github.com/tonyfischetti/clix.git ~/.lisp &&
    make -C ~/.lisp deps &&
    make -C ~/.lisp setup &&
    make -C ~/.lisp doctor
EOF


# set timezone
RUN <<EOF
    echo "America/New_York" | sudo tee -a /etc/timezone
EOF


# configuration changes
RUN <<EOF
    # SSHD config
    sudo perl -pi -e 's/^#? ?(LogLevel).+$/$1 VERBOSE/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^(# ?Authentication).+$/$1\nAllowUsers tony/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^#? ?(PermitRootLogin).+$/$1 no/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^#? ?(PasswordAuthentication).+$/$1 no/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^#? ?(PermitEmptyPasswords).+$/$1 no/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^#? ?(ClientAliveInterval).+$/$1 90/' /etc/ssh/sshd_config &&
    sudo perl -pi -e 's/^#? ?(ClientAliveCountMax).+$/$1 60/' /etc/ssh/sshd_config
EOF


# avr / arduino / esp toolchains
# Kept commented, at the bottom, as an uncomment-me recipe for the few
# machines that need it (verified working on trixie/arm64 2026-07-21;
# the esp32 core adds a couple of GB to the image).
# AVR is debian-native (same raw gcc-avr/avrdude workflow as the mac).
# arduino-cli is the headless CLI, pinned release binary, arch
# auto-detected.  ESP = the esp32 arduino core (espressif ships
# linux-arm64 toolchains) + debian's esptool for flashing.
# NB: containers can BUILD firmware anywhere, but FLASHING needs a
# linux host — Docker Desktop on macOS can't pass USB through.
# RUN <<EOF
#     sudo apt-get update  -qq &&
#     sudo apt-get install -qq -y gcc-avr binutils-avr avr-libc avrdude esptool &&
#     arch=$( [ "$(uname -m)" = "aarch64" ] && echo ARM64 || echo 64bit ) &&
#     wget -q "https://github.com/arduino/arduino-cli/releases/download/v1.5.1/arduino-cli_1.5.1_Linux_${arch}.tar.gz" -O /tmp/arduino-cli.tar.gz &&
#     sudo tar xzf /tmp/arduino-cli.tar.gz -C /usr/local/bin arduino-cli &&
#     rm /tmp/arduino-cli.tar.gz &&
#     arduino-cli core update-index --additional-urls https://espressif.github.io/arduino-esp32/package_esp32_index.json &&
#     arduino-cli core install arduino:avr &&
#     arduino-cli core install esp32:esp32 --additional-urls https://espressif.github.io/arduino-esp32/package_esp32_index.json &&
#     sudo usermod -a -G dialout $USERNAME
# EOF



CMD ["/usr/bin/zsh"]
