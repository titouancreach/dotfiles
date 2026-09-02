{ config, lib, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/Code/dotfiles";
  # out-of-store links: editable in place without a switch, and vim.pack needs
  # to write its lock file inside the nvim config dirs (store paths are read-only)
  outOfStore = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";

  cspellDict = name: version: hash: pkgs.stdenvNoCC.mkDerivation {
    pname = "cspell-${name}";
    inherit version;
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@cspell/${name}/-/${name}-${version}.tgz";
      inherit hash;
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/lib/node_modules/@cspell/${name}
      cp -r . $out/lib/node_modules/@cspell/${name}/
    '';
  };
in
{
  home.username = "titouancreach";
  home.homeDirectory = "/Users/titouancreach";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    btop
    eza
    jq
    gh
    herdr
    yazi
    nerd-fonts.jetbrains-mono

    neovim
    ripgrep
    fd
    ast-grep
    tree-sitter

    lua-language-server
    tailwindcss-language-server
    graphql-language-service-cli
    elmPackages.elm-language-server
    elmPackages.elm-format
    oxlint

    stylua
    oxfmt
    cspell
    (cspellDict "dict-medicalterms" "4.1.8" "sha512-MRA/6/KXoAena85lXrv++d0FRZ/j7uqqVQOvjiXfOoLRsChBrJrRAFvx9IRFoXM4uja67sg5QAqzFzzlg3B9gg==")
    markdownlint-cli
  ];

  home.sessionVariables = {
    EDITOR = "k";
    VISUAL = "k";
    NODE_OPTIONS = "--max_old_space_size=8192";
    # vim-herdr-navigation : TUI non-vim à qui laisser ctrl+hjkl au lieu de bouger
    # le focus de pane (regex ancrée sur le nom de process en minuscules).
    # fzf s'en sert pour ctrl+j/ctrl+k (item suivant/précédent).
    # Lu par le serveur herdr au démarrage -> `herdr server stop` pour recharger.
    HERDR_NAV_PASSTHROUGH_RE = "^(fzf|lazygit|k9s)$";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Titouan CREACH";
        email = "titouan.creach@gmail.com";
      };
      alias = {
        co = "checkout";
        up = "pull --rebase --autostash";
        graph = "log --graph --oneline";
      };
      branch.autosetupmerge = "always";
      fetch.prune = true;
      core = {
        editor = "vim";
        quotepath = "off";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
  };

  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.autojump.enable = true;

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    autocd = true;
    enableCompletion = true;
    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 50000;
      save = 10000;
      extended = true;
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = {
      ls = "eza --icons=auto";
      ll = "eza --icons=auto -la";
      la = "eza --icons=auto -a";
      lt = "eza --icons=auto --tree";
      gco = "git checkout";
    };
    initContent = lib.mkMerge [
      # mkOrder 550 = before compinit
      (lib.mkOrder 550 ''
        fpath=(
          "${dotfiles}/zsh/completions"
          "${config.home.profileDirectory}/share/zsh/site-functions"
          "$HOME/.nix-profile/share/zsh/site-functions"
          $fpath
        )
        if [[ -n "$IN_NIX_SHELL" ]]; then
          for input in ''${=nativeBuildInputs} ''${=buildInputs}; do
            [[ -d "$input/share/zsh/site-functions" ]] && fpath=("$input/share/zsh/site-functions" $fpath)
          done
        fi
      '')
      ''
        # before /usr/bin, otherwise Apple's git/... shadow the nix ones (macOS path_helper reorders)
        export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/usr/local/bin:$PATH
        setopt hist_verify interactive_comments

        zstyle ':completion:*' menu select
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' list-colors '''

        # prefix history search on up/down (what oh-my-zsh did): type "a", press up
        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey '^[[A' up-line-or-beginning-search    # up
        bindkey '^[OA' up-line-or-beginning-search    # up (app mode)
        bindkey '^[[B' down-line-or-beginning-search  # down
        bindkey '^[OB' down-line-or-beginning-search  # down (app mode)
        bindkey '^[[1;3C' forward-word   # alt+right
        bindkey '^[[1;3D' backward-word  # alt+left
        bindkey '^[[H' beginning-of-line
        bindkey '^[[F' end-of-line
        bindkey '^[[3~' delete-char

        [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

        export PATH="$PATH:$HOME/.dotnet/tools"
        export PATH="$HOME/.moon/bin:$PATH"
        [[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null
      ''
    ];
  };

  xdg.configFile = {
    "nvim".source = outOfStore "nvim";
    "nvim-kickstart".source = outOfStore "nvim-kickstart";
    # whole dir linked: custom-shader path is relative to the config file
    "ghostty".source = outOfStore "ghostty";
    # only config.toml is versioned; the rest of ~/.config/herdr is runtime state
    "herdr/config.toml".source = outOfStore "herdr/config.toml";
  };

  home.file = {
    "cspell.json".source = outOfStore "cspell.json";
    ".claude/skills/titouan-write-demo-steps".source = outOfStore "claude/skills/titouan-write-demo-steps";
    ".claude/skills/titouan-analyze-feature".source = outOfStore "claude/skills/titouan-analyze-feature";
  };
}
