#!/usr/bin/env bash
#
ln -s $PWD/nvim ~/.config/nvim

# install packer
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

ln -sf $PWD/zsh/zshrc $HOME/.zshrc
ln -sf $PWD/git/gitconfig $HOME/.gitconfig

mkdir -p $HOME/.ssh
ln -sf $PWD/ssh/config $HOME/.ssh/config

echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PackerSync 🎉"
echo "🎉 The neovim configuration is compatible with vscode: https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim 🎉"
