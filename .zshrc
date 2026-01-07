# .zshrc のコンパイル
if [ ! -f $DOTFILES_PATH/.zshrc.zwc -o $DOTFILES_PATH/.zshrc -nt $DOTFILES_PATH/.zshrc.zwc ]; then
  zcompile $DOTFILES_PATH/.zshrc
fi

# Zinitの設定
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# zinit
# プラグインの遅延読み込み（turboモード）
zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
      zsh-users/zsh-completions \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  atinit"zicompinit; zicdreplay" \
      zsh-users/zsh-syntax-highlighting

# 自動補完を有効にする
autoload bashcompinit && bashcompinit
# compinit高速化: ダンプファイルが新しければスキップ
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
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
  BUFFER=`history -n 1 | tail -r | awk '!a[$0]++' | fzf`
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
  echo "cd $(ghq root)/$dir\n\n"
  vcs_info
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

# ブランチ検索
function fbr() {
  local branches branch target result
  branches=$(git --no-pager branch -vv)
  branch=$(echo "$branches" | fzf +m)
  target=$(echo "$branch" | awk '{print $1}' | sed "s/.* //")
  result=$(git checkout $target 2>&1)
  echo "git checkout $target\n$result\n\n"
  vcs_info
  zle reset-prompt
}
zle -N fbr
bindkey '^F' fbr

# git worktree add
function gwa() {
  local branch
  branch=$(git branch | fzf | sed -e 's/^\* //g' | sed -e 's/^ *//g')
  if [[ -n "$branch" ]]; then
    local repo_name=$(basename $(git rev-parse --show-toplevel))
    local worktree_path="~/worktree/${repo_name}-${branch}"
    local command="git worktree add $worktree_path $branch"
    echo "$command\n"
    eval $command
    # シンボリックリンクを作成
    local expanded_path=$(eval echo $worktree_path)
    cd "$expanded_path"
    ln -s ~/.claude/.guri3 .
    echo "Created symlink: ~/.claude/.guri3 -> .\n"
    cd -
  fi
}

# git worktree remove
function gwr() {
  local worktree
  worktree=$(git worktree list | fzf | awk '{print $1}')
  if [[ -n "$worktree" ]]; then
    local command="git worktree remove $worktree"
    echo "$command\n"
    eval $command
  fi
}

# git worktree borrow
function gws() {
  local repo_root selection worktree_path borrowed_branch current_branch tmp_branch state_file stash_hash stash_ref stash_message checkout_output
  repo_root=$(command git rev-parse --show-toplevel 2>/dev/null) || { echo "gitリポジトリ内で実行してください。"; return 1; }

  state_file="${repo_root}/.git/worktree-switch-state"
  if [[ -f "$state_file" ]]; then
    echo "既に退避中のworktreeがあります。先にgwsrで復元してください。"
    return 1
  fi

  selection=$(
    command git worktree list --porcelain | awk '
      /^worktree / { wt=$0; sub(/^worktree /,"", wt) }
      /^branch / { br=$0; sub(/^branch refs\/heads\//,"", br) }
      /^detached/ { br="" }
      /^$/ {
        if (wt != "" && br != "") {
          printf "%s\t%s\n", wt, br
        }
        wt=""; br=""
      }
      END {
        if (wt != "" && br != "") {
          printf "%s\t%s\n", wt, br
        }
      }
    ' | fzf --with-nth=1,2 --delimiter=$'\t' --prompt='worktree> ' --height=40%
  )

  if [[ -z "$selection" ]]; then
    echo "worktreeの選択をキャンセルしました。"
    return 1
  fi

  worktree_path="${selection%%$'\t'*}"
  borrowed_branch="${selection##*$'\t'}"

  if [[ "$worktree_path" == "$repo_root" ]]; then
    echo "現在のworktreeは選択できません。"
    return 1
  fi

  current_branch=$(command git rev-parse --abbrev-ref HEAD)
  if [[ "$current_branch" == "$borrowed_branch" ]]; then
    echo "${borrowed_branch}は既にチェックアウトされています。"
    return 0
  fi

  tmp_branch="worktree-tmp/${borrowed_branch//\//-}-$(command date +%Y%m%d%H%M%S)"

  if ! command git -C "$worktree_path" checkout -b "$tmp_branch"; then
    echo "worktreeの退避に失敗しました。"
    return 1
  fi

  if [[ -n "$(command git status --porcelain)" ]]; then
    stash_message="gws-auto-stash $(command date +%Y%m%d%H%M%S)"
    if ! command git stash push -u -m "$stash_message" >/dev/null; then
      command git -C "$worktree_path" checkout "$borrowed_branch" >/dev/null 2>&1
      command git -C "$worktree_path" branch -D "$tmp_branch" >/dev/null 2>&1
      echo "作業中の変更をstashに退避できませんでした。"
      return 1
    fi
    stash_hash=$(command git rev-parse --verify stash@{0} 2>/dev/null)
    if [[ -n "$stash_hash" ]]; then
      stash_ref=$(command git stash list --format='%H %gd' | awk -v hash="$stash_hash" '$1 == hash { print $2; exit }')
      if [[ -n "$stash_ref" ]]; then
        printf "作業中の変更を%sに退避しました。\n" "$stash_ref"
      else
        printf "作業中の変更をstashに退避しました。\n"
      fi
    fi
  fi

  if ! checkout_output=$(command git checkout "$borrowed_branch" 2>&1); then
    if [[ -n "$stash_hash" ]]; then
      stash_ref=$(command git stash list --format='%H %gd' | awk -v hash="$stash_hash" '$1 == hash { print $2; exit }')
      if [[ -n "$stash_ref" ]]; then
        command git stash pop "$stash_ref" >/dev/null 2>&1 || printf "退避した変更(%s)の復元に失敗しました。手動でpopしてください。\n" "$stash_ref"
      fi
    fi
    command git -C "$worktree_path" checkout "$borrowed_branch" >/dev/null 2>&1
    command git -C "$worktree_path" branch -D "$tmp_branch" >/dev/null 2>&1
    printf "%s\n" "$checkout_output"
    printf "%sへの切り替えに失敗しました。\n" "$borrowed_branch"
    return 1
  fi

  if [[ -n "$checkout_output" ]]; then
    printf "%s\n" "$checkout_output"
  fi

  {
    printf "worktree_path=%q\n" "$worktree_path"
    printf "borrowed_branch=%q\n" "$borrowed_branch"
    printf "tmp_branch=%q\n" "$tmp_branch"
    printf "previous_branch=%q\n" "$current_branch"
    printf "stash_hash=%q\n" "$stash_hash"
  } >| "$state_file"

  printf "%sを%sに退避し、%sへ切り替えました。\n" "$worktree_path" "$tmp_branch" "$borrowed_branch"
}
zle -N gws
bindkey '^B' gws

# git worktree restore
function gwsr() {
  local repo_root state_file worktree_path borrowed_branch tmp_branch previous_branch current_branch delete_output stash_hash stash_ref restored_branch
  repo_root=$(command git rev-parse --show-toplevel 2>/dev/null) || { echo "gitリポジトリ内で実行してください。"; return 1; }

  state_file="${repo_root}/.git/worktree-switch-state"
  if [[ ! -f "$state_file" ]]; then
    echo "退避中のworktreeはありません。"
    return 1
  fi

  source "$state_file"

  if [[ -z "$worktree_path" || -z "$borrowed_branch" || -z "$tmp_branch" || -z "$previous_branch" ]]; then
    echo "退避情報の読み込みに失敗しました。"
    return 1
  fi

  if [[ ! -d "$worktree_path" ]]; then
    echo "退避したworktreeのディレクトリが存在しません: $worktree_path"
    return 1
  fi

  current_branch=$(command git rev-parse --abbrev-ref HEAD)
  restored_branch=0
  if [[ "$current_branch" == "$borrowed_branch" ]]; then
    if ! command git checkout "$previous_branch"; then
      echo "元のブランチ(${previous_branch})への切り替えに失敗しました。"
      return 1
    fi
    restored_branch=1
  else
    echo "現在のブランチは${current_branch}です。${previous_branch}への切り替えはスキップします。"
  fi

  if ! command git -C "$worktree_path" checkout "$borrowed_branch"; then
    echo "worktreeのブランチを${borrowed_branch}に戻せませんでした。"
    return 1
  fi

  if command git show-ref --verify --quiet "refs/heads/$tmp_branch"; then
    if ! delete_output=$(command git branch -d "$tmp_branch" 2>&1); then
      echo "$delete_output"
      echo "一時ブランチ${tmp_branch}の削除に失敗しました。必要であれば手動で削除してください。"
    fi
  fi

  if [[ -n "$stash_hash" ]]; then
    stash_ref=$(command git stash list --format='%H %gd' | awk -v hash="$stash_hash" '$1 == hash { print $2; exit }')
    if [[ -n "$stash_ref" ]]; then
      if [[ "$restored_branch" -eq 1 ]]; then
        if command git stash apply "$stash_ref" >/dev/null; then
          command git stash drop "$stash_ref" >/dev/null
          printf "自動退避した変更(%s)を復元しました。\n" "$stash_ref"
        else
          printf "自動退避した変更(%s)の適用に失敗しました。手動で対応してください。\n" "$stash_ref"
        fi
      else
        printf "自動退避した変更(%s)が残っています。適切なブランチで手動適用してください。\n" "$stash_ref"
      fi
    else
      printf "自動退避した変更が見つかりませんでした。既に手動で適用済みかもしれません。\n"
    fi
  fi

  printf "%sをworktree(%s)に戻しました。\n" "$borrowed_branch" "$worktree_path"

  command rm -f "$state_file"
  unset worktree_path borrowed_branch tmp_branch previous_branch stash_hash stash_ref restored_branch current_branch
}

# git wokrtree cd
function gwc() {
  local worktree
  worktree=$(git worktree list | fzf | awk '{print $1}')
  if [[ -n "$worktree" ]]; then
    cd "$worktree"
    echo "cd $worktree\n"
  fi
}

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
zstyle ':completion:*:default' menu select=1

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

# ssh
if [ -f ~/.ssh-agent ]; then
  . ~/.ssh-agent > /dev/null
fi
if [ -z "$SSH_AGENT_PID" ] || ! kill -0 $SSH_AGENT_PID; then
  ssh-agent > ~/.ssh-agent
  . ~/.ssh-agent > /dev/null
fi
ssh-add -l > /dev/null || ssh-add

# エイリアス
# Directory
alias dot="cd $DOTFILES_PATH"
alias dote="c $DOTFILES_PATH"
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
# Editor
# alias c='code .'
alias c='cursor .'
alias i='idea .'
# Claude Code

# ローカル設定の読み込み
if [ -f "$DOTFILES_PATH/.zshrc.local" ]; then
  source "$DOTFILES_PATH/.zshrc.local"
fi

if (which zprof > /dev/null 2>&1) ;then
  zprof
fi
