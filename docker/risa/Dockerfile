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
COPY etc.apt.preferences.d.bookworm.pref /etc/apt/preferences.d/bookworm.pref

# essential packages
RUN <<EOF
    apt-get update -qq &&
    apt-get upgrade -qq &&
    apt-get install -qq -y --no-install-recommends apt-utils &&
    apt-get install -qq -y --no-install-recommends                      \
      r-base sbcl git vim zsh wget curl gnupg                           \
      vim ack autotools-dev sbcl libsystemd0 libsystemd-dev ssh         \
      libcurses-perl build-essential tmux sudo htop cpanminus           \
      xz-utils automake autoconf ca-certificates libevent-dev           \
      debianutils diffutils moreutils ffmpeg figlet ncdu libxml2        \
      libncurses-dev libtool ncdu openssl python3-pip racket zip        \
      suckless-tools sqlite3 par pandoc pwgen ccze parallel pigz        \
      neofetch iotop imv renameutils apt-transport-https fd-find        \
      libnotify-dev colordiff dos2unix gawk jpegoptim keyutils          \
      patchutils bison libcurl4-openssl-dev libxml2-dev ecl             \
      apt-xapian-index libssl-dev rsync acpi visidata jags              \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev                 \
      libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev              \
      libudunits2-dev libgdal-dev libsqlite3-dev &&
    apt build-dep -y --no-install-recommends tmux zsh && # sbcl r-base
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

# # setup R
# NOTE: deciding not to compile the my bespoke R,
#       `apt build-dep` brings in too many packages
#       and makes the image size explode
# RUN <<EOF
#     git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
#     wget "https://cran.r-project.org/src/base/R-4/R-4.2.2.tar.gz" &&
#     tar xvfz R-4.2.2.tar.gz &&
#     cd R-4.2.2 &&
#     patch -p1 < ~/.rix/goodies/r-4.2.2-extended-history.patch &&
#     export CFLAGS="-fopenmp -O2 -march=native -mtune=native -pipe -pthread -DMZUNAME=\\\"Linux\\\" -DMZHOSTNAME=\\\"risa\\\" -DEXTENDED_HISTORY_FILE=\\\"/home/marvin/.r_extended_history-risa\\\"" &&
#     ./configure --prefix=/usr/local --enable-R-profiling --enable-memory-profiling --enable-java --enable-byte-compiled-packages --with-readline --without-recommended-packages --with-x --with-pcre2 --with-blas --with-lapack --with-gnu-ld --enable-R-shlib &&
#     sed -i 's/^LIBS .*/LIBS =  -lpcre2-8 -llzma -lbz2 -lz -lrt -ldl -lm -licuuc -licui18n -pthread -fopenmp/' Makeconf &&
#     make &&
#     sudo make install &&
#     cd .. &&
#     rm -rf R-4.2.2 &&
#     rm R-4.2.2.tar.gz &&
#     cd ~/.rix &&
#     R_LIBS=~/local/R_libs/ ./install.sh
# EOF

# setup R
RUN <<EOF
    git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
    cd ~/.rix &&
    R_LIBS=~/local/R_libs/ ./install.sh
    sudo ln -s /usr/bin/R /usr/local/bin/R
    sudo ln -s /usr/bin/Rscript /usr/local/bin/Rscript
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

# nala apt frontend
RUN <<EOF
    wget "https://deb.volian.org/volian/pool/main/n/nala-legacy/nala-legacy_0.11.0_amd64.deb" -O nala-legacy.deb &&
    sudo apt install ./nala-legacy.deb -y &&
    rm nala-legacy.deb
EOF

# # setup lisp
# # NOTE: deciding not to compile the my bespoke sbcl...
# #       `apt build-dep` brings in too many packages
# #       and makes the image size explode
# RUN <<EOF
#     wget "https://github.com/sbcl/sbcl/archive/refs/tags/sbcl-2.3.0.tar.gz" -O sbcl.tar.gz &&
#     tar xvfz sbcl.tar.gz &&
#     cd sbcl-sbcl-2.3.0 &&
#     export CFLAGS="-O2 -march=native -mtune=native -pipe" &&
#     echo '"2.3.0"' > version.lisp-expr &&
#     sh make.sh --prefix=/usr/local --dynamic-space-size=13Gb --fancy --with-sb-core-compression &&
#     cd doc/manual &&
#     make &&
#     cd ../../ &&
#     sudo sh install.sh &&
#     cd ~ &&
#     rm sbcl.tar.gz &&
#     rm -rf sbcl-sbcl-2.3.0 &&
#     git clone https://github.com/tonyfischetti/clix.git ~/.lisp &&
#     cd ~/.lisp &&
#     ./install.sh &&
#     sbcl --eval '(quit)' &&
#     ~/.zsh/bin/update-lisp-cores.sh
# EOF

# setup lisp
RUN <<EOF
    git clone https://github.com/tonyfischetti/clix.git ~/.lisp &&
    cd ~/.lisp &&
    ./install.sh &&
    sudo ln -s /usr/bin/sbcl /usr/local/bin/sbcl &&
    sbcl --eval '(quit)'
EOF

# setup cmus
RUN <<EOF
    sudo apt build-dep cmus -y --no-install-recommends &&
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

# setup zpaq
RUN <<EOF
    git clone https://github.com/tonyfischetti/zpaq &&
    cd zpaq &&
    make &&
    sudo make install &&
    cd .. &&
    rm -rf zpaq
EOF

# setup powershell
RUN <<EOF
    wget "https://github.com/PowerShell/PowerShell/releases/download/v7.3.0/powershell_7.3.0-1.deb_amd64.deb" -O powershell.deb &&
    sudo apt install ./powershell.deb &&
    rm powershell.deb
EOF

# dropbox
RUN <<EOF
    sudo apt install -qq -y --no-install-recommends python3-gpg &&
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
    sudo apt-get install -qq -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin -y &&
    sudo usermod -a $USERNAME -G docker
EOF

# setup nodejs
RUN <<EOF
    sudo apt install -y -qq --no-install-recommends -t bookworm libnode-dev nodejs npm
EOF

    # npm install -g yarn
    # curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -  &&
    # sudo apt update &&
    # sudo apt install -y nodejs &&
    # sudo apt remove cmdtest &&
    # curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - &&
    # echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee -a /etc/apt/sources.list &&
    # sudo apt-get update &&
    # sudo apt-get install yarn -y




#
# # supplemental packages, update packages, and clean up
# RUN <<EOF
#     sudo apt install -t bookworm libnode-dev
#     # &&
#     # devtools, sf, ___
#
#     # options(mc.cores = parallel::detectCores())
#     # rstan_options(auto_write = TRUE)
#
#     # install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
#     # install.packages(c("coda","mvtnorm","devtools","loo","dagitty","shape"))
#     # devtools::install_github("rmcelreath/rethinking")
#
#     sudo apt update &&
#     sudo apt upgrade -y &&
#     sudo apt autoremove -y &&
#     sudo update-apt-xapian-index
# EOF

CMD ["/usr/local/bin/zsh"]

# python3-lxml
# python3-pil
# python3-flask
# python3-sqlalchemy

# ECL??!

# THE POST INSTALL


# npm:
# hexo-cli?
# snazzy?
# serve
# yarn
# neovim
# shelljs
# gulp-cli

# USE MULTISTAGE BUILDS TO CUT DOWN ON THE SIZE!

# pip

# /home/tony/.rix/pkg-list-vulcan
# still need stan

# rstan
# cmdstanr
# rethinking
#
# PSQL CLIENT?!!?
# VPN CLIENT??!?
#
# python: lxml, etc....
# javascript: gulp, dotenv, etc....
#
# Do I have what I need to compile styx????

# install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# install.packages("rstan")
# install.packages(c("coda","mvtnorm","devtools","loo","dagitty","shape"))
# devtools::install_github("rmcelreath/rethinking")
