#!/bin/bash
set -eu

DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"

# Homebrew（未インストールならCommand Line Toolsごと入る）
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 現在のシェルにbrewのPATHを通す（Apple Silicon / Intel 両対応）
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ghqの規約に従った場所にリポジトリを配置する（ghq導入前のためgit cloneで代替）
if [ ! -d "$DOTFILES_PATH" ]; then
  mkdir -p "$(dirname "$DOTFILES_PATH")"
  git clone https://github.com/guri3/dotfiles.git "$DOTFILES_PATH"
fi

make -C "$DOTFILES_PATH" all
