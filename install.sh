export DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"

# Homebrew パッケージのインストール
brew bundle --file="$DOTFILES_PATH/Brewfile"

ln -s $DOTFILES_PATH/.tmux.conf ~/.tmux.conf
ln -s $DOTFILES_PATH/.vimrc ~/.vimrc
ln -s $DOTFILES_PATH/.zshenv ~/.zshenv
ln -s $DOTFILES_PATH/.zshrc ~/.zshrc
ln -s $DOTFILES_PATH/git/.gitconfig ~/.gitconfig
ln -s $DOTFILES_PATH/git/.gitconfig.local ~/.gitconfig.local
ln -s $DOTFILES_PATH/git/.gitignore.global ~/.gitignore
ln -s $DOTFILES_PATH/.bashrc ~/.bashrc
ln -s $DOTFILES_PATH/.bash_profile ~/.bash_profile
ln -s $DOTFILES_PATH/.pryrc ~/.pryrc
ln -s $DOTFILES_PATH/.vim ~/.vim
ln -s $DOTFILES_PATH/.git_template ~/.git_template
ln -s $DOTFILES_PATH/dot_config/borders ~/.config/borders
ln -s $DOTFILES_PATH/dot_config/mise ~/.config/mise
ln -s $DOTFILES_PATH/dot_config/starship.toml ~/.config/starship.toml
ln -s $DOTFILES_PATH/.aerospace.toml ~/.aerospace.toml
# Codex
ln -s $DOTFILES_PATH/dot_ai/AGENTS.md ~/.codex/AGENTS.md
ln -s $DOTFILES_PATH/dot_codex/config.toml ~/.codex/config.toml
# Claude
ln -s $DOTFILES_PATH/dot_claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s $DOTFILES_PATH/dot_claude/settings.json ~/.claude/settings.json
ln -s $DOTFILES_PATH/dot_claude/scripts ~/.claude/scripts
# Cursor
ln -s $DOTFILES_PATH/dot_ai/AGENTS.md ~/.cursor/AGENTS.md
# tmux
ln -s $DOTFILES_PATH/.config/tmux ~/.config/tmux
# Ghostty
ln -s $DOTFILES_PATH/dot_config/ghostty/config ~/.config/ghostty/config
# Herdr
ln -s $DOTFILES_PATH/dot_config/herdr/config.toml ~/.config/herdr/config.toml

# Skills (APM 経由でグローバルインストール)
for skill in create-pr empirical-prompt-tuning git-commit rule-feedback solve split-pr; do
  apm install -g "guri3/dotfiles/dot_ai/skills/$skill"
done

# Agents (APM 経由でグローバルインストール)
for agent in feedback implementer planner reviewer system-designer test-checker; do
  apm install -g "guri3/dotfiles/dot_ai/agents/$agent.agent.md"
done
