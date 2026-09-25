{ config, lib, pkgs, neovim-nightly-overlay, nodejs, ... }:

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
    nodejs
    gh
    herdr
    yazi
    nerd-fonts.jetbrains-mono

    # nightly (0.13.0-dev) from the overlay flake input: native multicursor
    neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  # i3-style tiling, one workspace per app. Based on AeroSpace's i3 preset, but
  # workspaces/moves are on ctrl: on the French Mac layout alt+digit and
  # alt+shift+letter type { } [ ] | etc.
  # Keys are physical qwerty positions, so ctrl-1 = the "&" key, alt-z = AZERTY "w".
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      config-version = 2;
      persistent-workspaces = [ ];
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      mode.main.binding =
        let
          # key "0" -> workspace 10, like i3
          workspaces = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ];
          ws = k: if k == "0" then "10" else k;
          perWorkspace = f: builtins.listToAttrs (map f workspaces);
        in
        perWorkspace (k: { name = "ctrl-${k}"; value = "workspace ${ws k}"; })
        // perWorkspace (k: { name = "ctrl-shift-${k}"; value = "move-node-to-workspace ${ws k}"; })
        // {
          # ctrl-hjkl stays for vim/herdr pane navigation
          alt-h = "focus --boundaries-action wrap-around-the-workspace left";
          alt-j = "focus --boundaries-action wrap-around-the-workspace down";
          alt-k = "focus --boundaries-action wrap-around-the-workspace up";
          alt-l = "focus --boundaries-action wrap-around-the-workspace right";
          ctrl-alt-h = "move left";
          ctrl-alt-j = "move down";
          ctrl-alt-k = "move up";
          ctrl-alt-l = "move right";

          alt-f = "fullscreen";
          alt-s = "layout v_accordion"; # i3 'layout stacking'
          alt-z = "layout h_accordion"; # i3 'layout tabbed' (mod+w), AZERTY "w" key
          alt-e = "layout tiles horizontal vertical"; # i3 'layout toggle split'
          alt-shift-space = "layout floating tiling"; # i3 'floating toggle'

          alt-tab = "workspace-back-and-forth";
          alt-shift-c = "reload-config";
          alt-r = "mode resize";
        };
      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
      on-window-detected = [
        { "if".app-id = "company.thebrowser.Browser"; run = "move-node-to-workspace 1"; }
        { "if".app-id = "com.google.Chrome"; run = "move-node-to-workspace 1"; }
        { "if".app-id = "com.tinyspeck.slackmacgap"; run = "move-node-to-workspace 3"; }
        { "if".app-id = "notion.id"; run = "move-node-to-workspace 4"; }
        { "if".app-id = "us.zoom.xos"; run = "move-node-to-workspace 5"; }
      ];
    };
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


      ''
    ];
  };

  xdg.configFile = {
    "nvim".source = outOfStore "nvim-kickstart";
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
