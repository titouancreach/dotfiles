#!/usr/bin/env sh


# install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'


mkdir -p $HOME/.config/nvim
ln -sf $PWD/nvim/init.vim $HOME/.config/nvim/init.vim
ln -sf $PWD/zsh/zshrc $HOME/.zshrc

git config --global alias.co 'checkout'
git config --global alias.up 'pull --rebase --autostash'
git config --global fetch.prune true


echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PlugInstall, then :source ~/.config/nvim/init.vim 🎉"
