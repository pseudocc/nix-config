# vim: et:ts=2:sw=2
{
  description = "pseudoc";

  inputs = {
    # Nix
    nixpkgs.url = "github:pseudocc/nixpkgs/nixos-26.05";
    # nixpkgs.url = "git+file:///home/pseudoc/projects/github/nixpkgs?ref=nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";

    ghostty.url = "github:ghostty-org/ghostty/tip";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypriio = {
      url = "github:pseudocc/hypriio";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent/v2026.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
  let
    flakes = inputs // rec {
      me = import ./me.nix;
      lib = import ./lib.nix;
      colors = import ./colors.nix;

      modules.ghostty = import ./modules/ghostty.nix;
      packages.neovim-terminal = ./packages/neovim-terminal.nix;
    };
  in {
    nixosConfigurations = {
      zipzap = nixpkgs.lib.nixosSystem rec {
        specialArgs = { inherit flakes; };
        system = "x86_64-linux";
        modules = [
          ./nixos.nix
          ./zipzap/nixos.nix
        ];
      };
      ziczac = nixpkgs.lib.nixosSystem rec {
        specialArgs = { inherit flakes; };
        system = "x86_64-linux";
        modules = [
          ./nixos.nix
          ./ziczac/nixos.nix
          ./hermes-agent.nix
        ];
      };
    };
  };
}
