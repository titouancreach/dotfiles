# Configuration

Here is the list of the dotfiles I use.

(I keep my original .vimrc and stuff into archive)

## home-manager

Everything (binaries, zsh, git, direnv, config symlinks) is declared in
`home.nix` and applied with home-manager:

```
nix run home-manager -- switch --flake ~/Code/dotfiles -b hm-backup   # first time
home-manager switch --flake ~/Code/dotfiles                          # after any edit
nix flake update && home-manager switch --flake ~/Code/dotfiles      # bump nixpkgs
```

`-b hm-backup` moves pre-existing files (old symlinks, ~/.gitconfig) aside on
the first run.

I use it to install my lsp servers instead of Mason.

## Dotfiles


### Nerd font

`nerd-fonts.jetbrains-mono` is in the nix profile, but macOS only scans
`~/Library/Fonts`, so the files have to be linked there:

```bash
if [ "$(uname)" = "Darwin" ]; then
  mkdir -p "$HOME/Library/Fonts"
  ln -sf "$HOME/.nix-profile/share/fonts/truetype/NerdFonts/JetBrainsMono/"*.ttf "$HOME/Library/Fonts/"
fi
```

On Linux fontconfig finds `~/.nix-profile/share/fonts` on its own.

### Ghostty

```bash
ln -sfn $PWD/ghostty $HOME/.config/ghostty
```

Nord theme, JetBrains Mono NL, no italics, `cursor_smear.glsl` cursor shader.
The whole directory is linked because `custom-shader` is resolved relative to
the config file. Ghostty also reads
`~/Library/Application Support/com.mitchellh.ghostty/config`; keep that one
empty so there is a single source of truth.

### zsh

```bash
ln -sf $PWD/zsh/zshrc $HOME/.zshrc
```

No oh-my-zsh. Completions, fzf and autojump come from the nix profile;
starship is the prompt.

### git

```bash
ln -sf $PWD/git/gitconfig $HOME/.gitconfig
```

### Neovim

```bash
ln -s $PWD/nvim-kickstart ~/.config/nvim-kickstart
NVIM_APPNAME=nvim-kickstart nvim
```

### herdr

```bash
mkdir -p $HOME/.config/herdr
ln -sf $PWD/herdr/config.toml $HOME/.config/herdr/config.toml
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
```


### Claude Code skills


## Screenshot
