export DOTFILES_PATH="$HOME/ghq/github.com/guri3/dotfiles"

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
ln -s $DOTFILES_PATH/dot_codex/AGENTS.md ~/.codex/AGENTS.md
ln -s $DOTFILES_PATH/dot_codex/config.toml ~/.codex/config.toml
# Claude
ln -s $DOTFILES_PATH/dot_claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s $DOTFILES_PATH/dot_claude/commands ~/.claude/commands
ln -s $DOTFILES_PATH/dot_claude/settings.json ~/.claude/settings.json
# Cursor
ln -s $DOTFILES_PATH/dot_cursor/AGENTS.md ~/.cursor/AGENTS.md
ln -s $DOTFILES_PATH/dot_cursor/agents ~/.cursor/agents
ln -s $DOTFILES_PATH/dot_cursor/commands ~/.cursor/commands
ln -s $DOTFILES_PATH/dot_cursor/skills ~/.cursor/skills
