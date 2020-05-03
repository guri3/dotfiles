# .zshrc のコンパイル
if [ ! -f $DOTFILES_PATH/.zshrc.zwc -o $DOTFILES_PATH/.zshrc -nt $DOTFILES_PATH/.zshrc.zwc ]; then
  zcompile $DOTFILES_PATH/.zshrc
fi

# zplugの設定
source ~/.zplug/init.zsh

# zpulg
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# インストール
if ! zplug check --verbose; then
  printf 'Install? [y/N]: '
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

# 自動補完を有効にする
autoload -Uz compinit; compinit
# コマンドプロンプトに色をつける
autoload -Uz colors; colors
zstyle ':completion:*' verbose yes
export LSCOLORS=exfxcxdxbxegedabagacad
LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

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
bindkey '^P' history-beginning-search-backward-end
bindkey '^N' history-beginning-search-forward-end

# コマンド検索
function command-history-search() {
  BUFFER=`{ history -n 1 | tail -r ; cat ~/.command.txt } | awk '!a[$0]++' | fzf`
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N command-history-search
bindkey '^R' command-history-search

# ghq検索
function ghq-list-search() {
  local dir="$(ghq list | fzf)"
  if [[ ! -z $dir ]]; then
    cd "$(ghq root)/$dir"
  fi
  zle reset-prompt
}
zle -N ghq-list-search
bindkey '^E' ghq-list-search

# GitHubのURLを開く
function gh-open-search() {
  local repo="$(ghq list | fzf | sed -e 's/github.com\///g')"
  if [[ ! -z $repo ]]; then
    BUFFER="gh repo view $repo --web"
    CURSOR=$#BUFFER
    zle reset-prompt
  fi
}
zle -N gh-open-search
bindkey '^B' gh-open-search

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
function add_line {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}
function emoji {
  if [[ $? != 0 ]]; then
    echo -n '\U1F914'
  elif [[ $(pwd) = $HOME ]]; then
    echo -n '\U1F3E0'
  elif [[ $(pwd) =~ "$DOTFILES_PATH" ]]; then
    echo -n '\U1F527'
  elif [[ $(pwd) =~ "$HOME/ghq" ]]; then
    echo -n '\U1F4BB'
  else
    echo -n '\U1F4C2'
  fi
}
function current_path {
}
precmd() { add_line; vcs_info }

# プロンプト（左）
PROMPT='$(emoji) %~ ${vcs_info_msg_0_}
%{%F{202}%}❯%{%f%}%{%F{221}%}❯%{%f%}%{%F{027}%}❯%{%f%} '
# tmuxのwindowを左右に分けるコマンド
s2() {
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

# エイリアス
# Directory
alias dot="cd $DOTFILES_PATH"
alias dotv="code $DOTFILES_PATH"
alias goc='cd $GOPATH/src/github.com/guri3'
# General
alias ls='ls -G'
alias la='ls -aG'
alias ll='ls -aGl'
alias so='source'
alias vi='vim'
# gitエイリアス
alias g='git'
alias gst='git status'
alias gs='git status -s -b'
alias ga='git add'
alias gb='git branch'
alias gcm='git commit -m'
alias gd='git diff'
alias gdc='git diff --cached'
alias gpu='git push'
alias gpuh='git push origin HEAD'
alias gpl='git pull'
alias gco='git checkout'
alias gc='git branch | fzf | sed -e "s/\* //g" | xargs git checkout'
alias gl='git log --oneline'
alias glg='git log --graph --date=short --pretty=format:"%Cgreen%h %cd %Cblue%cn %Creset%s %Cred%d%Creset"'
alias galg='git log --graph --all --date=short --pretty=format:"%Cgreen%h %cd %Cblue%cn %Creset%s %Cred%d%Creset"'
# Rubyエイリアス
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

if (which zprof > /dev/null 2>&1) ;then
  zprof
fi
