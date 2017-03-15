# zplugの設定
source ~/.zplug/init.zsh

# zpulg
zplug "zsh-users/zsh-history-substring-search"
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "zsh-users/zsh-syntax-highlighting", defer:3
zplug "zsh-users/zsh-completions"

# インストール
if ! zplug check --verbose; then
  printf 'Install? [y/N]: '
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# 基本機能
# 自動補完を有効にする
autoload -U compinit; compinit
# コマンドプロンプトに色をつける
autoload -U colors; colors

# ディレクトリ移動など
# cd した先のディレクトリをディレクトリスタックに追加する
# `cd +<Tab>` でディレクトリの履歴が表示され、そこに移動できる
setopt auto_pushd
# pushd したとき、ディレクトリがすでにスタックに含まれていればスタックに追加しない
setopt pushd_ignore_dups
# 入力したコマンドがすでにコマンド履歴に含まれる場合、履歴から古いほうのコマンドを削除する
setopt hist_ignore_all_dups

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
zstyle ':completion:*:default' menu select=1

# エイリアス
alias la='ls -a'
alias ll='ls -la'
alias so='source'
alias vi='vim'
# railsエイリアス
alias be='bundle exec'
alias rs='bundle exec rails s'
alias rc='bundle exec rails c'

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/shims:$PATH"
