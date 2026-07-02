DOTFILES_PATH := $(HOME)/ghq/github.com/guri3/dotfiles
REPO_URL := https://github.com/guri3/dotfiles.git

.DEFAULT_GOAL := install

# symlinkの向き先を固定するため、ghqの規約通りの場所で実行する。
# 規約外の場所で実行された場合は、規約の場所へのcloneを済ませた上でそちらで実行し直す。
ifneq ($(CURDIR),$(DOTFILES_PATH))

GOALS := $(or $(MAKECMDGOALS),install)

.PHONY: $(GOALS)
$(GOALS):
	@if [ ! -d "$(DOTFILES_PATH)" ]; then \
		mkdir -p "$(dir $(DOTFILES_PATH))"; \
		git clone "$(REPO_URL)" "$(DOTFILES_PATH)"; \
	fi
	$(MAKE) -C "$(DOTFILES_PATH)" $@

else

.PHONY: install brew brew-check shell git vim pry tmux aerospace borders mise mise-install starship codex claude cursor cursor-extensions cursor-dump ghostty herdr skills agents

install: brew shell git vim pry tmux aerospace borders mise mise-install starship codex claude cursor cursor-extensions ghostty herdr skills agents

# Homebrew本体はインストール方法が変わりうるため自動化せず、存在チェックのみ行う
brew-check:
	@command -v brew >/dev/null 2>&1 || { echo "Homebrewが見つからない。https://brew.sh の手順でインストールしてから再実行すること"; exit 1; }

# Homebrew パッケージのインストール
brew: brew-check
	brew bundle --file="$(DOTFILES_PATH)/Brewfile"

# Shell (zsh / bash)
shell:
	ln -sfn "$(DOTFILES_PATH)/.zshenv" "$(HOME)/.zshenv"
	ln -sfn "$(DOTFILES_PATH)/.zshrc" "$(HOME)/.zshrc"
	ln -sfn "$(DOTFILES_PATH)/.bashrc" "$(HOME)/.bashrc"
	ln -sfn "$(DOTFILES_PATH)/.bash_profile" "$(HOME)/.bash_profile"

# Git
git:
	ln -sfn "$(DOTFILES_PATH)/git/.gitconfig" "$(HOME)/.gitconfig"
	ln -sfn "$(DOTFILES_PATH)/git/.gitconfig.local" "$(HOME)/.gitconfig.local"
	ln -sfn "$(DOTFILES_PATH)/git/.gitignore.global" "$(HOME)/.gitignore"
	ln -sfn "$(DOTFILES_PATH)/.git_template" "$(HOME)/.git_template"

# Vim
vim:
	ln -sfn "$(DOTFILES_PATH)/.vimrc" "$(HOME)/.vimrc"
	ln -sfn "$(DOTFILES_PATH)/.vim" "$(HOME)/.vim"

# Pry
pry:
	ln -sfn "$(DOTFILES_PATH)/.pryrc" "$(HOME)/.pryrc"

# tmux
tmux:
	ln -sfn "$(DOTFILES_PATH)/.tmux.conf" "$(HOME)/.tmux.conf"
	mkdir -p "$(HOME)/.config"
	ln -sfn "$(DOTFILES_PATH)/.config/tmux" "$(HOME)/.config/tmux"

# AeroSpace
aerospace:
	ln -sfn "$(DOTFILES_PATH)/.aerospace.toml" "$(HOME)/.aerospace.toml"

# Borders
borders:
	mkdir -p "$(HOME)/.config"
	ln -sfn "$(DOTFILES_PATH)/dot_config/borders" "$(HOME)/.config/borders"

# mise
mise:
	mkdir -p "$(HOME)/.config"
	ln -sfn "$(DOTFILES_PATH)/dot_config/mise" "$(HOME)/.config/mise"

# miseで管理するツールのインストール（mise本体はbrew経由で入るためbrewに依存）
mise-install: brew mise
	mise install --yes

# Starship
starship:
	mkdir -p "$(HOME)/.config"
	ln -sfn "$(DOTFILES_PATH)/dot_config/starship.toml" "$(HOME)/.config/starship.toml"

# Codex
codex:
	mkdir -p "$(HOME)/.codex"
	ln -sfn "$(DOTFILES_PATH)/dot_ai/AGENTS.md" "$(HOME)/.codex/AGENTS.md"
	ln -sfn "$(DOTFILES_PATH)/dot_codex/config.toml" "$(HOME)/.codex/config.toml"

# Claude
claude:
	mkdir -p "$(HOME)/.claude"
	ln -sfn "$(DOTFILES_PATH)/dot_claude/CLAUDE.md" "$(HOME)/.claude/CLAUDE.md"
	ln -sfn "$(DOTFILES_PATH)/dot_claude/settings.json" "$(HOME)/.claude/settings.json"
	ln -sfn "$(DOTFILES_PATH)/dot_claude/scripts" "$(HOME)/.claude/scripts"

# Cursor
CURSOR_USER_DIR := $(HOME)/Library/Application Support/Cursor/User

# Cursor自身が設定ファイルを書き換えるため、symlinkではなくcpで反映する
cursor:
	mkdir -p "$(HOME)/.cursor" "$(CURSOR_USER_DIR)"
	ln -sfn "$(DOTFILES_PATH)/dot_ai/AGENTS.md" "$(HOME)/.cursor/AGENTS.md"
	rm -f "$(CURSOR_USER_DIR)/settings.json" "$(CURSOR_USER_DIR)/keybindings.json"
	cp "$(DOTFILES_PATH)/dot_cursor/settings.json" "$(CURSOR_USER_DIR)/settings.json"
	cp "$(DOTFILES_PATH)/dot_cursor/keybindings.json" "$(CURSOR_USER_DIR)/keybindings.json"

# Cursorの拡張機能を一覧ファイルからインストールする（cursorコマンドはcask経由で入る）
cursor-extensions:
	xargs -L1 cursor --install-extension < "$(DOTFILES_PATH)/dot_cursor/extensions.txt"

# Cursor側の現状（設定・拡張機能一覧）をdotfilesに取り込む
cursor-dump:
	cp "$(CURSOR_USER_DIR)/settings.json" "$(DOTFILES_PATH)/dot_cursor/settings.json"
	cp "$(CURSOR_USER_DIR)/keybindings.json" "$(DOTFILES_PATH)/dot_cursor/keybindings.json"
	cursor --list-extensions | sort > "$(DOTFILES_PATH)/dot_cursor/extensions.txt"

# Ghostty
ghostty:
	mkdir -p "$(HOME)/.config/ghostty"
	ln -sfn "$(DOTFILES_PATH)/dot_config/ghostty/config" "$(HOME)/.config/ghostty/config"

# Herdr
herdr:
	mkdir -p "$(HOME)/.config/herdr"
	ln -sfn "$(DOTFILES_PATH)/dot_config/herdr/config.toml" "$(HOME)/.config/herdr/config.toml"

# Skills (APM 経由でグローバルインストール)
skills:
	for skill in create-pr empirical-prompt-tuning git-commit rule-feedback solve split-pr; do \
		apm install -g "guri3/dotfiles/dot_ai/skills/$$skill"; \
	done

# Agents (APM 経由でグローバルインストール)
agents:
	for agent in feedback implementer planner reviewer system-designer test-checker; do \
		apm install -g "guri3/dotfiles/dot_ai/agents/$$agent.agent.md"; \
	done

endif
