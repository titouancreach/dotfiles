# Configuration

Here is the list of the dotfiles I use.

To install, you need to have GNU Stow, and run ```install.sh```

## Neovim 

I use [vim-plug](https://github.com/junegunn/vim-plug) as a plugin manager, you must to install it before using this configuration.
Then, type ```:PlugInstall``` in Neovim.

Siver searcher (a.k.a Ag) is required to search through the code and for FZF, on Ubuntu

```bash
sudo apt install silversearcher-ag
```

Install xclip in order to make the + register to work
```
sudo apt install xclip
```


![screenshot](./screenshot/vim.png)


# tmux

I use [tpm](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager) as a plugin manager for tmux, you must install it before using this configuration.
Then, type `C-a + I` in tmux.

# zshrc

My zshrc use antigen as a plugin manager and oh-my-zshrc.
