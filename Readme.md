# Configuration

Dotfiles managed with home-manager: packages, zsh, git, direnv/starship/fzf/
autojump wiring, and config symlinks are all declared in `home.nix`.

(I keep my original .vimrc and stuff into archive)

## Usage

```
nix run home-manager -- switch --flake ~/Code/dotfiles -b hm-backup   # first time
home-manager switch --flake ~/Code/dotfiles                          # after any edit
nix flake update && home-manager switch --flake ~/Code/dotfiles      # bump nixpkgs
```

`-b hm-backup` moves pre-existing files aside on the first run.

LSP servers come from `home.packages` instead of Mason.

Config dirs (nvim, ghostty, herdr, cspell, Claude skills) are linked with
`mkOutOfStoreSymlink`: editable in place, no switch needed, and vim.pack can
write its lock file.

## Notes

### Nerd font

home-manager copies fonts from `home.packages` into
`~/Library/Fonts/HomeManager` on macOS. On Linux fontconfig finds
`~/.nix-profile/share/fonts` on its own.

### Ghostty

Nord theme, JetBrains Mono NL, no italics, `cursor_smear.glsl` cursor shader.
The whole directory is linked because `custom-shader` is resolved relative to
the config file. Ghostty also reads
`~/Library/Application Support/com.mitchellh.ghostty/config`; keep that one
empty so there is a single source of truth.

### zsh

No oh-my-zsh. Declared in `programs.zsh` (history, aliases, bindkeys);
completions, fzf and autojump come from their home-manager modules; starship
is the prompt.

### Neovim

Two configs: `nvim` (legacy) and `nvim-kickstart`, both linked into
`~/.config`. Run the kickstart one with:

```bash
NVIM_APPNAME=nvim-kickstart nvim
```

### herdr

Only `config.toml` is versioned; the rest of `~/.config/herdr` is runtime
state. The plugin install stays manual:

```bash
herdr plugin install paulbkim-dev/vim-herdr-navigation --yes
```

## Screenshot
