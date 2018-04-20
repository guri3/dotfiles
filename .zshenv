# Generail
#----------------------------------------------------
export LANG=ja_JP.UTF-8
export EDITOR=vim


# Path
#----------------------------------------------------
# dotfiles
export DOTFILES_PATH="$HOME/dotfiles"

# ruby
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"

# python
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/anaconda3/bin:$PATH"

# PostgreSQL
export PGDATA=/usr/local/var/postgres

# android
export ANDROID_HOME="$HOME/Library/Android/sdk"

# go
export GOPATH="$HOME/.go"


# Search path
#----------------------------------------------------
# local
export PATH=/usr/local/bin:$PATH
export PATH=/usr/bin:$PATH
