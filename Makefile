DOTFILES_PATH := $(HOME)/ghq/github.com/guri3/dotfiles

# symlinkの向き先を固定するため、ghqの規約通りの場所に配置されていることを強制する
ifneq ($(CURDIR),$(DOTFILES_PATH))
$(error dotfilesは $(DOTFILES_PATH) に配置して実行すること。READMEのセットアップ手順を参照)
endif

.DEFAULT_GOAL := install

.PHONY: install brew brew-check shell git vim pry tmux aerospace borders mise mise-install starship codex claude cursor ghostty herdr skills agents

install: brew shell git vim pry tmux aerospace borders mise mise-install starship codex claude cursor ghostty herdr skills agents

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
cursor:
	mkdir -p "$(HOME)/.cursor"
	ln -sfn "$(DOTFILES_PATH)/dot_ai/AGENTS.md" "$(HOME)/.cursor/AGENTS.md"

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
