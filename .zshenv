# Generail
#----------------------------------------------------
setopt no_global_rcs
export LANG=ja_JP.UTF-8
export EDITOR=vim

# Search path
#----------------------------------------------------
# local
export PATH=/usr/local/bin:$PATH
export PATH=/usr/bin:$PATH

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
export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"

# go
export GOPATH="$HOME/projects/gocode"
export PATH="$(go env GOPATH)/bin:$PATH"

# node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# crystal
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig
