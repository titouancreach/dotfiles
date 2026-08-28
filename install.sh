#!/usr/bin/env bash
#
# All dev binaries (git, rg, fzf, LSP servers, formatters, ...) come from ONE
# nix profile declared in ./flake.nix. Needs nix with flakes enabled.
#   update later with: nix flake update && nix profile upgrade dotfiles
nix profile add "$PWD"

# macOS does not scan ~/.nix-profile/share/fonts; link the nerd font into ~/Library/Fonts
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Fonts"
  ln -sf "$HOME/.nix-profile/share/fonts/truetype/NerdFonts/JetBrainsMono/"*.ttf "$HOME/Library/Fonts/"
fi

# ghostty — config + cursor shader (whole dir, custom-shader path is relative to it)
ln -sfn $PWD/ghostty $HOME/.config/ghostty

ln -s $PWD/nvim ~/.config/nvim
ln -sf $PWD/zsh/zshrc $HOME/.zshrc
ln -sf $PWD/cspell.json $HOME/cspell.json

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
