#!/usr/bin/env sh


# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

ln -sf $PWD/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $PWD/zsh/zshrc $HOME/.zshrc

echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PlugInstall, then :source ~/.config/nvim/init.vim 🎉"
