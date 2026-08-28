{
  description = "Titouan dotfiles";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAll (pkgs:
        let
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
            git
            git-lfs
            eza
            autojump
            fzf
            jq
            gh
            herdr
            starship
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
        };
      });
    };
}
