# zmodload zsh/zprof && zprof

# Generail
#----------------------------------------------------
setopt no_global_rcs
export LANG=ja_JP.UTF-8
export EDITOR=vim

# Path
#----------------------------------------------------
# local
export PATH="$HOME/bin:$PATH"

# Homebrew (Apple Silicon)
export PATH="/opt/homebrew/bin:$PATH"

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"

# php
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Android
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
export PATH="$HOME/Library/Android/sdk/emulator:$PATH"

# Rancher Desktop
export PATH="$HOME/.rd/bin:$PATH"

# Claude Code
export PATH="$HOME/.claude/local/node_modules/.bin:$PATH"

# Initialization
#----------------------------------------------------
# anyenv
eval "$(anyenv init - zsh)"

# Starship
eval "$(starship init zsh)"

# Options
#----------------------------------------------------
# fzf
export FZF_DEFAULT_OPTS="--reverse --height 50% --border --ansi"

# PostgreSQL
export PGDATA=/usr/local/var/postgres

# android
export ANDROID_HOME="$HOME/Library/Android/sdk"

# crystal
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# dotfiles
export DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"
