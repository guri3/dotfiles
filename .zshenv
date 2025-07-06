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
export PATH=/opt/homebrew/bin:$PATH

# Path
#----------------------------------------------------
# dotfiles
export DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init - zsh)"

# PostgreSQL
export PGDATA=/usr/local/var/postgres

# android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# crystal
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# php
export PATH="$HOME/.composer/vendor/bin:$PATH"

# fzf
#----------------------------------------------------
export FZF_DEFAULT_OPTS="--reverse --height 50% --border --ansi"

# Rancher Desktop
export PATH="$PATH:$HOME/.rd/bin"

# Android
export PATH="$PATH:$HOME/Library/Android/sdk/emulator"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Claude Code
export PATH="$PATH:$HOME/.claude/local/node_modules/.bin"
