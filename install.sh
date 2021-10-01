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


if [[ $HAS_CODE -eq 1 ]]; then
  #if mac
  if [[ $OSTYPE == 'darwin'* ]]; then
      ln -sf $PWD/vscode/settings.json "$HOME/Library/ApplicationSupport/Code/User/settings.json"
  fi

  code --install-extension eamodio.gitlens --force
  code --install-extension esbenp.prettier-vscode --force
  code --install-extension GitHub.copilot --force
  code --install-extension GitHub.github-vscode-theme --force
  code --install-extension medo64.render-crlf --force
  code --install-extension ms-azuretools.vscode-docker --force
  code --install-extension ms-dotnettools.blazorwasm-companion --force
  code --install-extension ms-dotnettools.csharp --force
  code --install-extension ms-dotnettools.vscode-dotnet-runtime --force
  code --install-extension ms-vscode-remote.remote-containers --force
  code --install-extension ms-vscode-remote.remote-ssh --force
  code --install-extension ms-vscode-remote.remote-ssh-edit --force
  code --install-extension ms-vscode-remote.remote-wsl --force
  code --install-extension ms-vscode-remote.vscode-remote-extensionpack --force
  code --install-extension ms-vscode.azure-account --force
  code --install-extension PKief.material-icon-theme --force
  code --install-extension vscodevim.vim --force
  code --install-extension william-voyek.vscode-nginx --force
  code --install-extension bradlc.vscode-tailwindcss --force

fi

echo "🎉 Installation completed 🎉"
echo "🎉 Run vim and install plugins via :PlugInstall, then :source ~/.config/nvim/init.vim 🎉"
