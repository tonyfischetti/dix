# syntax=docker/dockerfile:1.3-labs

# Environment variable DOCKER_BUILDKIT must be set to "1"
# before building this image

FROM debian:bullseye

LABEL maintainer="tony.fischetti@gmail.com"

ENV TERM=screen-256color
ENV LANG=C.UTF-8
ENV SHELL=/usr/bin/zsh

ARG USERNAME=marvin
ARG USER_UID=1000
ARG USER_GID=$USER_UID


COPY etc.apt.sources.list /etc/apt/sources.list

# essential packages
RUN <<EOF
    apt-get update -qq &&
    apt-get install -qq -y --no-install-recommends apt-utils &&
    apt-get install -qq -y --no-install-recommends                      \
      r-base r-base-dev git nodejs npm vim zsh wget curl gnupg          \
      vim ack autotools-dev sbcl libsystemd0 libsystemd-dev ssh         \
      libcurses-perl build-essential tmux sudo htop cpanminus           \
      xz-utils automake autoconf ca-certificates libevent-dev           \
      debianutils diffutils moreutils ffmpeg figlet ncdu libxml2        \
      libncurses-dev libtool ncdu openssl python3-pip racket zip        \
      suckless-tools sqlite3 par pandoc pwgen ccze parallel pigz        \
      neofetch iotop imv renameutils apt-transport-https fd-find        \
      libnotify-dev colordiff dos2unix gawk jpegoptim keyutils          \
      patchutils bison libcurl4-openssl-dev libxml2-dev ecl             \
      apt-xapian-index libssl-dev rsync acpi visidata                   \
      libsqlite3-dev &&
    apt build-dep -y tmux sbcl zsh &&
    apt-get clean &&
    cpanm install Term::Animation
EOF

# create non-root user
RUN <<EOF
    groupadd --gid $USER_GID $USERNAME &&
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME &&
    usermod -a $USERNAME -G sudo &&
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


# setup nodejs
RUN <<EOF
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -  &&
    sudo apt update &&
    sudo apt install -y nodejs &&
    sudo apt remove cmdtest &&
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - &&
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee -a /etc/apt/sources.list &&
    sudo apt-get update &&
    sudo apt-get install yarn -y
EOF

# setup R
RUN <<EOF
    git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
    cd ~/.rix &&
    R_LIBS=~/local/R_libs/ ./install.sh
EOF

# setup zsh
RUN <<EOF
    git clone https://github.com/tonyfischetti/zsh &&
    cd zsh &&
    ./Util/preconfig &&
    ./configure --enable-pcre --enable-cap --enable-unicode9                \
        --enable-multibyte --with-tcsetpgrp                                 \
        --enable-custom-patchlevel="zsh-tony-extended-patch" &&
    make &&
    sudo make install &&
    cd $HOME &&
    git clone https://github.com/tonyfischetti/zix.git ~/.zsh &&
    cd ~/.zsh &&
    ./install.sh &&
    rm -rf ~/zsh &&
    echo "/usr/local/bin/zsh" | sudo tee -a /etc/shells &&
    sudo usermod -s /usr/local/bin/zsh $USERNAME
EOF

# setup lisp
RUN <<EOF
    git clone https://github.com/tonyfischetti/clix.git ~/.lisp &&
    cd ~/.lisp &&
    ./install.sh &&
    sudo ln -s /usr/bin/sbcl /usr/local/bin/sbcl &&
    sbcl --eval '(quit)'
EOF

# setup tmux
RUN <<EOF
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

# setup zpaq
RUN <<EOF
    git clone https://github.com/tonyfischetti/zpaq &&
    cd zpaq &&
    make &&
    sudo make install &&
    cd .. &&
    rm -rf zpaq
EOF

# setup vim
RUN <<EOF
    wget "https://github.com/neovim/neovim/releases/download/v0.8.1/nvim-linux64.deb" -O nvim.deb &&
    sudo apt install ./nvim.deb &&
    sudo apt install -qq -y --no-install-recommends python3-pynvim          \
      python3-greenlet python3-msgpack lua-luv libtermkey1 libvterm0        \
      python3-neovim libluajit-5.1-2 libmsgpackc2 &&
    mkdir -p ~/.config &&
    git clone https://github.com/tonyfischetti/vix.git ~/.config/nvim &&
    cd ~/.config/nvim &&
    ./install.sh 2>&1 &&
    cd ~ &&
    rm nvim.deb &&
    cpanm -n Neovim::Ext
EOF

# setup cmus
RUN <<EOF
    sudo apt build-dep cmus -y &&
    git clone https://github.com/tonyfischetti/cmus &&
    cd cmus &&
    ./configure &&
    make &&
    sudo make install &&
    cd ../ &&
    rm -rf cmus &&
    git clone https://github.com/tonyfischetti/cmix.git ~/cmus &&
    mkdir $HOME/music
EOF

# setup powershell
RUN <<EOF
    wget "https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell_7.3.0-1.deb_amd64.deb" -O powershell.deb &&
    sudo apt install ./powershell.deb &&
    rm powershell.deb
EOF

# nala apt frontend
RUN <<EOF
    wget "https://deb.volian.org/volian/pool/main/n/nala-legacy/nala-legacy_0.11.0_amd64.deb" -O nala-legacy.deb &&
    sudo apt install ./nala-legacy.deb -y &&
    rm nala-legacy.deb
EOF

# # dropbox
RUN <<EOF
    sudo apt install python3-gpg -y &&
    wget "https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2020.03.04_amd64.deb" -O dropbox.deb &&
    sudo apt install ./dropbox.deb -y &&
    rm dropbox.deb
EOF

# set up Docker sources
RUN <<EOF
    sudo mkdir -p /etc/apt/keyrings &&
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &&
    echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee -a /etc/apt/sources.list &&
    sudo apt-get update &&
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y 
EOF

# supplemental packages, update packages, and clean up
RUN <<EOF
    # supplemental packages here
    sudo apt update &&
    sudo apt upgrade -y &&
    sudo apt autoremove -y
EOF

CMD ["/usr/local/bin/zsh"]

