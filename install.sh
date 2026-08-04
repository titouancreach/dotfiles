#!/usr/bin/env bash
#
ln -s $PWD/nvim ~/.config/nvim

# install packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# ln -sf $PWD/zsh/zshrc $HOME/.zshrc
# ln -sf $PWD/git/gitconfig $HOME/.gitconfig
#
# mkdir -p $HOME/.ssh
# ln -sf $PWD/ssh/config $HOME/.ssh/config

# herdr — only config.toml is versioned; the rest of ~/.config/herdr is runtime
# state (sockets, logs, session snapshots, plugin checkouts). See herdr/README.md.
mkdir -p $HOME/.config/herdr
ln -sf $PWD/herdr/config.toml $HOME/.config/herdr/config.toml
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes

# Claude personal skills
mkdir -p $HOME/.claude/skills
ln -sf $PWD/claude/skills/titouan-write-demo-steps $HOME/.claude/skills/titouan-write-demo-steps
ln -sf $PWD/claude/skills/titouan-analyze-feature $HOME/.claude/skills/titouan-analyze-feature

echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PackerSync 🎉"
echo "🎉 The neovim configuration is compatible with vscode: https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim 🎉"
