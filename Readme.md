# Configuration

Here is the list of the dotfiles I use.

(I keep my original .vimrc as nvim.old, since I used it since school)

## Binaries: one nix profile, no Mason

Every CLI tool, LSP server, formatter and linter the configs rely on is listed
in `flake.nix` (`buildEnv` bundle `dotfiles-tools`).

```
nix profile add ~/Code/dotfiles      # install everything
nix flake update                     # bump nixpkgs
nix profile upgrade dotfiles-tools   # rebuild the bundle
```

Neovim does not install anything itself: `lsp.lua` just `vim.lsp.enable`s
servers found on `$PATH`. Exceptions: `ocamllsp` comes from the opam switch,
`gleam` from per-project nix dev shells, `tsgo`/`oxlint` prefer the project's
`node_modules/.bin`.

## Neovim

On Linux install xclip so the '+' register works: `sudo apt install xclip`.

### Nerdfont
https://www.nerdfonts.com/

### Screenshot

![screenshot](./screenshot/vim.png)
