#!/usr/bin/env sh


# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

mkdir -p $HOME/.config/nvim
ln -sf $PWD/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $PWD/zsh/zshrc $HOME/.zshrc
ln -sf $PWD/git/gitconfig $HOME/.gitconfig

mkdir -p $HOME/.ssh
ln -sf $PWD/ssh/config $HOME/.ssh/config

#if mac
if [[ $OSTYPE == 'darwin'* ]]; then
    ln -sf $PWD/vscode/settings.json "$HOME/Library/ApplicationSupport/Code/User/settings.json"
fi

echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PlugInstall, then :source ~/.config/nvim/init.vim 🎉"
