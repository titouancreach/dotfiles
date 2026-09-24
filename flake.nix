{
  description = "Titouan dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Neovim nightly (0.13.0-dev) for the native multicursor (|multicursor|, `Q`).
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Same nixpkgs rev as inato-marketplace's `nixpkgs-node` input, so both
    # resolve to the same nodejs_24 store path instead of a second copy.
    nixpkgs-node.url = "github:nixos/nixpkgs/ac6b2166e7a9375683b8e98f860f273222337b16";
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly-overlay, nixpkgs-node }: {
    homeConfigurations."titouancreach" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = {
        inherit neovim-nightly-overlay;
        nodejs = nixpkgs-node.legacyPackages.aarch64-darwin.nodejs_24;
      };
      modules = [ ./home.nix ];
    };
  };
}
