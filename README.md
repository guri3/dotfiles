# dotfiles

dotfilesリポジトリです。開発環境の設定ファイルを管理しています。

## フォルダ構成

```
.
├── .bash_profile          # Bash プロファイル設定
├── .bashrc                # Bash 設定
├── .gitignore             # Git 除外設定
├── .ideavimrc             # IntelliJ IDEA Vim設定
├── .pryrc                  # Pry設定
├── .tmux.conf             # tmux設定
├── .vim/                  # Vim設定ディレクトリ
│   └── colors/
│       └── iceberg.vim    # Icebergカラースキーム
├── .vimrc                 # Vim設定
├── .zshenv                # Zsh環境変数設定
├── .zshrc                 # Zsh設定
├── colors/                # カラースキーム
│   ├── claude/
│   │   └── claude.itermcolors
│   ├── iceberg/
│   │   ├── Iceberg.terminal
│   │   └── iceberg.vim
│   └── solarized/
│       ├── solarized.terminal
│       └── solarized.vim
├── dot_claude/            # Claude設定
│   ├── CLAUDE.md
│   ├── commands/          # コマンド定義
│   │   ├── create-pr.md
│   │   ├── implementation-design.md
│   │   ├── implementation-todo.md
│   │   ├── rename-tmux-window.md
│   │   └── start-implementation.md
│   └── settings.json
├── dot_codex/             # Codex設定
│   └── config.toml
├── dot_config/            # 設定ファイル
│   ├── mise/
│   │   └── config.toml
│   └── starship.toml      # Starshipプロンプト設定
├── git/                   # Git設定
│   ├── .gitconfig
│   └── .gitignore.global
├── scripts/               # スクリプト
│   └── colcheck.sh
├── install.sh             # インストールスクリプト
└── README.md
```
