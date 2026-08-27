{
  description = "Titouan dotfiles; every dev binary in one nix profile (replaces Mason + brew scatter)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs:
        let
          # cspell dictionary from npm, exposed at lib/node_modules/@cspell/<name>
          # so cspell.json can import it via ../../.nix-profile/lib/node_modules/...
          # (medicalterms is not in cspell's bundled dicts; haskell is).
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
        default = pkgs.buildEnv {
          name = "dotfiles-tools";
          paths = with pkgs; [
            # --- shell / CLI (zshrc, gitconfig, herdr) ---------------------
            git
            git-lfs # gitconfig [filter "lfs"]
            eza # ls/ll/la/lt aliases
            autojump # omz plugin
            fzf # ~/.fzf.zsh
            # tmux
            jq
            gh # octo.nvim + CLI
            herdr

            # --- neovim + search backends ----------------------------------
            neovim
            ripgrep # telescope live_grep, fff, checkhealth
            fd
            ast-grep # `sg`: telescope ast_grep + LSP ast_grep
            tree-sitter # nvim-treesitter (main branch) compiles parsers with the CLI

            # --- LSP servers (were Mason-managed) --------------------------
            lua-language-server # lua_ls
            tailwindcss-language-server # tailwindcss
            graphql-language-service-cli # graphql
            elmPackages.elm-language-server # elmls
            elmPackages.elm-format # elmls formatting
            # typescript-go # tsgo fallback when no node_modules/.bin/tsgo
            oxlint # fallback when no node_modules/.bin/oxlint
            # ocamllsp: NOT here on purpose — must match the opam switch compiler,
            # so it stays installed via `opam install ocaml-lsp-server`.
            # gleam: per-project via nix dev shells (see lsp.lua).

            # --- formatters / linters --------------------------------------
            stylua # conform: lua
            oxfmt # conform: ts/js/json fallback
            cspell # none-ls cspell.nvim
            (cspellDict "dict-medicalterms" "4.1.8" "sha512-MRA/6/KXoAena85lXrv++d0FRZ/j7uqqVQOvjiXfOoLRsChBrJrRAFvx9IRFoXM4uja67sg5QAqzFzzlg3B9gg==")
            markdownlint-cli # nvim-lint: markdown

            # --- debug adapters --------------------------------------------
            # delve # nvim-dap-go
          ];
        };
      });
    };
}
