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
# cdコマンドをつけなくてもディレクトリ移動
setopt auto_cd
cdpath=(.. ~ ~/projects)

# コマンド履歴
# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY
# 履歴を共有
setopt share_history
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# ヒストリを自動展開
setopt hist_expand
# コマンド履歴検索
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# 登録コマンドとコマンド履歴から検索
function peco-command-selection() {
  BUFFER=`{ history -n 1 | tail -r ; cat ~/.command.txt } | peco`
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-command-selection
bindkey '^R' peco-command-selection

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
zstyle ':completion:*:default' menu select=1

# VCSの情報を取得するzsh関数
autoload -Uz vcs_info

# PROMPT変数内で変数参照
setopt prompt_subst

zstyle ':vcs_info:git:*' check-for-changes true #formats 設定項目で %c,%u が使用可
zstyle ':vcs_info:git:*' stagedstr "%F{green}" #commit されていないファイルがある
zstyle ':vcs_info:git:*' unstagedstr "%F{magenta}" #add されていないファイルがある
zstyle ':vcs_info:*' formats "%F{cyan}%c%u(%b)%f" #通常
zstyle ':vcs_info:*' actionformats '[%b|%a]' #rebase 途中,merge コンフリクト等 formats 外の表示

# %b ブランチ情報
# %a アクション名(mergeなど)
# %c changes
# %u uncommit

# プロンプト表示直前に vcs_info 呼び出し
precmd () { vcs_info }

# プロンプト（左）
PROMPT='
%~ ${vcs_info_msg_0_}
%{[${fg[yellow]%}%}%n%{${reset_color}%}]$ '

# tmuxのwindowを左右に分けるコマンド
s3() {
  tmux split-window -h
}
# tmuxのwindowを3つに分けるコマンド
s3() {
  tmux split-window -h
  tmux split-window -v -t `tmux display-message -p '#I'`.2
}
# tmuxのwindowを4等分するコマンド
s4 () {
  tmux split-window -h
  tmux split-window -v -t `tmux display-message -p '#I'`.1
  tmux split-window -v -t `tmux display-message -p '#I'`.3
}
# git checkout + peco
gco () {
  git branch |
  peco |
  sed -e 's/\* //g' |
  xargs git checkout
}

# エイリアス
alias la='ls -a'
alias ll='ls -la'
alias so='source'
alias vi='vim'
# gitエイリアス
alias g='git'
alias s='git s'
alias st='git st'
alias a='git add .'
alias c='git commit -m'
alias d='git d'
alias pu='git push'
alias spu='git push origin HEAD'
alias pl='git pull'
alias c='git checkout'
alias k='git checkout'
alias l='git l'
# railsエイリアス
alias be='bundle exec'
alias rs='bundle exec rails s'
alias rc='bundle exec rails c'
alias bi='bundle install --path vendor/bundle'
# dockerエイリアス
alias do='docker'
alias doc='docker-compose'
alias dcb='docker-compose build'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
