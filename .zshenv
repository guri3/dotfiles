# zmodload zsh/zprof && zprof

# Generail
#----------------------------------------------------
setopt no_global_rcs
export LANG=ja_JP.UTF-8
export EDITOR=vim

# Search path
#----------------------------------------------------
# local
export PATH="$HOME/bin:$PATH"
export PATH=/usr/bin:$PATH
export PATH=/usr/local/bin:$PATH

# Path
#----------------------------------------------------
# dotfiles
export DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"

# anyenv
eval "$(anyenv init -)"

# PostgreSQL
export PGDATA=/usr/local/var/postgres

# android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# crystal
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# php
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/krb5/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/icu4c/lib/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/libedit/lib/pkgconfig"
export PHP_BUILD_CONFIGURE_OPTS="--with-bz2=/usr/local/opt/bzip2 --with-iconv=/usr/local/opt/libiconv"

# fzf
#----------------------------------------------------
export FZF_DEFAULT_OPTS="--reverse --height 50% --border --ansi"

