{
  description = "Titouan dotfiles; every dev binary in one nix profile (replaces Mason + brew scatter)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs: {
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
            markdownlint-cli # nvim-lint: markdown

            # --- debug adapters --------------------------------------------
            # delve # nvim-dap-go
          ];
        };
      });
    };
}
