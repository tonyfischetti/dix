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
    apt-get update -qq                                                  &&
    apt-get upgrade -qq                                                 &&
    apt-get install -qq -y --no-install-recommends apt-utils            &&
    apt-get install -qq -y --no-install-recommends git neovim ack       \
              wget curl build-essential sqlite3 fzf ripgrep             &&
    apt-get install -qq -y --no-install-recommends                      \
       zsh gnupg autotools-dev sbcl libsystemd-dev ssh                  \
      build-essential tmux sudo htop cpanminus                          \
      xz-utils automake autoconf ca-certificates libevent-dev           \
      debianutils diffutils moreutils ffmpeg figlet ncdu libxml2        \
      libncurses-dev libtool ncdu openssl python3-pip racket zip        \
      suckless-tools par pandoc pwgen ccze parallel pigz                \
      iotop imv renameutils apt-transport-https fd-find                 \
      libnotify-dev colordiff dos2unix gawk jpegoptim keyutils          \
      patchutils bison libcurl4-openssl-dev libxml2-dev ecl             \
      apt-xapian-index libssl-dev rsync acpi visidata jags              \
      libfontconfig1-dev libharfbuzz-dev libfribidi-dev pass            \
      libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev              \
      libudunits2-dev libgdal-dev libsqlite3-dev gfortran less          \
      ecl postgresql-client libfmt-dev libssl-dev libre2-dev zoxide     \
      libboost-dev libspdlog-dev maven debconf-utils r-base nala        &&
    apt build-dep -y --no-install-recommends tmux                       &&
    apt-get clean                                                       &&
    cpanm install Term::Animation
EOF

# languages
RUN <<EOF
    apt-get update -qq
    apt-get upgrade -qq
    apt-get install -qq -y --no-install-recommends luarocks cpanminus \
              ruby gem ack clang r-base python3-neovim ruby-neovim    \
              golang default-jdk &&
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > $HOME/rustup.sh &&
    bash $HOME/rustup.sh -y &&
    rm $HOME/rustup.sh
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
    cd $HOME &&
    git clone https://github.com/tonyfischetti/zix.git ~/.zsh &&
    cd ~/.zsh &&
    ./install.sh &&
    rm -rf ~/zsh &&
    sudo usermod -s /usr/bin/zsh $USERNAME
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

# install nodejs
RUN <<EOF
    curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh &&
    sudo -E bash nodesource_setup.sh &&
    sudo apt -qq -y install nodejs &&
    rm nodesource_setup.sh &&
    npm i -g neovim
EOF

# setup R
# RUN <<EOF
#     git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
#     wget "https://cran.r-project.org/src/base/R-4/R-4.3.1.tar.gz" -O R.tar.gz &&
#     tar xvfz R.tar.gz --one-top-level=R --strip-components 1 &&
#     cd R &&
#     patch -p1 < ~/.rix/goodies/r-4.2.2-extended-history.patch &&
#     export CFLAGS="-fopenmp -O2 -march=native -mtune=native -pipe -pthread -DMZUNAME=\\\"Linux\\\" -DMZHOSTNAME=\\\"risa\\\" -DEXTENDED_HISTORY_FILE=\\\"/home/tony/.r_extended_history-risa\\\"" &&
#     ./configure --prefix=/usr/local --enable-R-profiling --enable-memory-profiling --enable-java --enable-byte-compiled-packages --with-readline --without-recommended-packages --with-x --with-pcre2 --with-blas --with-lapack --with-gnu-ld --enable-R-shlib &&
#     sed -i 's/^LIBS .*/LIBS =  -lpcre2-8 -llzma -lbz2 -lz -lrt -ldl -lm -licuuc -licui18n -pthread -fopenmp -ltirpc/' Makeconf &&

#     make &&
#     sudo make install &&
#     cd .. &&
#     rm -rf R &&
#     rm R.tar.gz &&
#     cd ~/.rix &&
#     R_LIBS=~/local/R_libs/ ./install.sh
# EOF

# setup R
RUN <<EOF
    git clone https://github.com/tonyfischetti/rix.git ~/.rix/ &&
    cd ~/.rix &&
    R_LIBS=~/local/R_libs/ ./install.sh
EOF

# setup lisp
# # NOTE: deciding not to compile the my bespoke sbcl...
# #       `apt build-dep` brings in too many packages
# #       and makes the image size explode
# RUN <<EOF
#     wget "https://github.com/sbcl/sbcl/archive/refs/tags/sbcl-2.3.0.tar.gz" -O sbcl.tar.gz &&
#     tar xvfz sbcl.tar.gz &&
#     cd sbcl-sbcl-2.3.0 &&
#     export CFLAGS="-O2 -march=native -mtune=native -pipe" &&
#     # echo '"2.3.0"' > version.lisp-expr &&
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

# setup neovim
RUN <<EOF
    # if the latest is needed
    # wget "https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz" -O $HOME/neovim.tar.gz &&
    # sudo tar xvfz neovim.tar.gz --strip-components=1 -C /usr/local &&
    # rm -rf $HOME/neovim.tar.gz &&
    git clone https://github.com/tonyfischetti/vix.git ~/.config/nvim &&
    cd ~/.config/nvim &&
    make install &&
    nvim --headless +qall
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

# # python packages
# RUN <<EOF
#     sudo apt install -qq -y --no-install-recommends python3-flask           \
#       python3-networkx python3-numpy python3-scipy python3-pandas           \
#       python3-matplotlib python3-twython python3-lxml python3-pudb          \
#       python3-sqlalchemy python3-pil python3-ipython python3-notebook       \
#       python3-jupyter-console pipx &&
#     pipx install master-sake
# EOF

# # R packages
# RUN <<EOF
#     R_LIBS=~/local/R_libs/ R -e 'install.packages(c("anytime", "assertr",
#       "assertthat", "backports", "base64enc", "BBmisc", "BH", "bit64", "boot",
#       "broom", "callr", "caret", "caTools", "checkmate", "cli", "clipr",
#       "coda", "colorspace", "commonmark", "compareDF", "corrgram", "curl",
#       "daggity", "DBI", "dbplyr", "desc", "DescTools", "devtools", "diffobj",
#       "digest", "doParallel", "DT", "dtplyr", "e1071", "ellipsis", "epitools",
#       "evaluate", "fabletools", "ff", "forcats", "foreach", "fs",
#       "getopt", "ggrepel", "gitcreds", "glmnet", "glue", "googledrive",
#       "googlesheets4", "gridExtra", "gtable", "gtools", "haven", "here",
#       "hms", "htmlTable", "htmltools", "httpcode", "httpuv", "janitor",
#       "jsonlite", "KernSmooth", "knitr", "lattice", "lazyeval", "libbib",
#       "lme4", "lobstr", "loo", "lubridate", "maptools", "markdown", "MASS",
#       "memoise", "mgcv", "mice", "modelr", "munsell", "mvtnrorm", "nlme",
#       "openssl", "openxlsx", "pbapply", "permute", "pillar", "pkgbuild",
#       "plyr", "png", "pROC", "progress", "progressr", "promises", "ps",
#       "psych", "purrr", "quantmod", "R6", "randomForest", "ranger", "raster",
#       "RCurl", "readr", "readxl", "recipes", "reclin2", "RecordLinkage",
#       "rematch", "rematch2", "rex", "rfUtilities", "rgdal", "rhub", "rio",
#       "rjags", "rjson", "rland", "rmarkdown", "robustbase", "ROCR",
#       "roxygen2", "RPostgreSQL", "rprojroot", "rsample", "rsconnect",
#       "RSQLite", "rstudioapi", "rsyslog", "R.utils", "rvest", "scales",
#       "selectr", "sessioninfo", "sf", "shape", "shiny", "shinydashboard",
#       "sourcetools", "sp", "SparseM", "sqldf", "SSLASSO", "stringdist",
#       "stringr", "testthat", "tibble", "tidyquant", "tidyr", "tidyselect",
#       "tidyverse", "timechange", "timeDate", "tseries", "tsfeatures",
#       "tstibble", "TTR", "tzdb", "units", "urltools", "utf8", "uuid", "V8",
#       "vcd", "vegan", "VIM", "viridis", "viridisLite", "vroom", "warp",
#       "whoami", "withr", "xgboost", "XML", "xml2", "xmlparsedata", "xtable",
#       "xts", "yaml", "yardstick", "zip", "zoo", "packrat", "plotly",
#       "testthat", "covr", "rhub"))' &&
#     R_LIBS=~/local/R_libs/ R -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))' &&
#     R_LIBS=~/local/R_libs/ R -e 'install.packages("rstan")'
# EOF

# update apt xapian index
RUN <<EOF
    sudo update-apt-xapian-index
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

# - - - - - - #

# CMD ["/usr/local/bin/zsh"]
CMD ["/usr/bin/zsh"]

# ARDUINO STUFF
# THE POST INSTALL
# PSQL CLIENT?!!?
# VPN CLIENT??!?
