# Configuration

Here is the list of dotfiles I use.

To install, run `install.sh`. It will create symlinks to the right files.

Use `HAS_CODE=1 ./install.sh` to setup vscode. It will link the settings.json and install the extensions. (Mac only).

## Neovim 

Siver searcher (a.k.a Ag) is required to search through the code, and for FZF:

```bash
sudo apt install silversearcher-ag
# or
brew install the_silver_searcher
```

Install xclip in order to make the '+' register to work
```
sudo apt install xclip
```


![screenshot](./screenshot/vim.png)
