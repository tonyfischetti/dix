# syntax=docker/dockerfile:1.3-labs

# Environment variable DOCKER_BUILDKIT must be set to "1"
# before building this image

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
    apt-get install -qq -y git sudo wget curl
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


# setup zsh
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y procps fzf zoxide zsh wget build-essential libcurses-perl cpanminus nala &&
    sudo cpanm install Term::Animation &&
    git clone https://github.com/tonyfischetti/zix.git $HOME/.zsh &&
    cd $HOME/.zsh &&
    ./install.sh &&
    make &&
    sudo usermod -s /usr/bin/zsh $USERNAME
EOF


# install r
RUN <<EOF
    sudo apt install -qq -y build-essential libcurl4-openssl-dev libssl-dev libxml2-dev r-base &&
    git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
    cd ~/.rix &&
    R_LIBS=~/local/R_libs/ ./install.sh
EOF


# install nodejs
RUN <<EOF
    curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh &&
    sudo -E bash nodesource_setup.sh &&
    sudo apt -qq -y install nodejs &&
    rm nodesource_setup.sh &&
    npm i -g neovim
EOF


# setup neovim
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y fzf build-essential curl libcurl4-openssl-dev libssl-dev libxml2-dev r-base par pandoc &&
    wget "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-arm64.tar.gz" -O $HOME/neovim.tar.gz &&
    # wget "https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz" -O $HOME/neovim.tar.gz &&
    sudo tar xvfz neovim.tar.gz --strip-components=1 -C /usr/local &&
    rm -rf $HOME/neovim.tar.gz &&
    git clone https://github.com/tonyfischetti/vix.git ~/.config/nvim &&
    cd ~/.config/nvim &&
    make install &&
    nvim --headless +qall
EOF


# other languages
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y                                            \
      luarocks ruby gem clang python3-neovim ruby-neovim golang            \
      default-jdk maven racket ecl python3-pip rustup ghc cabal-install &&
    rustup default stable
EOF


# setup tmux
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt build-dep -y --no-install-recommends tmux &&
    sudo apt-get clean &&
    git clone https://github.com/tonyfischetti/tmux &&
    cd tmux &&
    git checkout tony-changes &&
    ./autogen.sh &&
    ./configure &&
    make &&
    sudo make install &&
    cd ../ &&
    rm -rf tmux &&
    git clone https://github.com/tonyfischetti/tmix.git ~/.tmux &&
    ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
EOF


# setup lisp
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y sbcl smenu &&
    git clone https://github.com/tonyfischetti/clix.git ~/.lisp &&
    cd ~/.lisp &&
    ./install.sh &&
    sudo ln -s /usr/bin/sbcl /usr/local/bin/sbcl &&
    sbcl --eval '(quit)'
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
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt build-dep -y cmus &&
    git clone https://github.com/tonyfischetti/cmus $HOME/cmus &&
    cd cmus &&
    ./configure &&
    make &&
    sudo make install &&
    cd $HOME &&
    rm -rf cmus &&
    git clone https://github.com/tonyfischetti/cmix.git ~/cmus &&
    mkdir $HOME/music
EOF


# other packages
RUN <<EOF
    sudo apt-get update  -qq &&
    sudo apt-get upgrade -qq &&
    sudo apt-get install -qq -y                                            \
      apt-utils ack ripgrep htop sqlite3 ssh moreutils ffmpeg figlet ncdu  \
      suckless-tools pandoc pwgen parallel iotop imv renameutils fd-find   \
      libnotify-dev colordiff dos2unix gawk jpegoptim keyutils patchutils  \
      rsync acpi visidata jags libfontconfig1-dev libharfbuzz-dev          \
      libfribidi-dev pass libfreetype6-dev libpng-dev libtiff5-dev         \
      libjpeg-dev libudunits2-dev libgdal-dev libsqlite3-dev gfortran less \
      postgresql-client libfmt-dev libssl-dev libre2-dev libboost-dev      \
      libspdlog-dev debconf-utils
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



CMD ["/usr/bin/zsh"]
