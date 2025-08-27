# vim: et:ts=2:sw=2
{
  description = "pseudoc";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-mine.url = "github:pseudocc/nixpkgs/intel-npu";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Ghostty Terminal (Customized)
    ghostty.url = "github:pseudocc/ghostty";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    nixvim = {
      url = "github:pseudocc/nixvim/suffix-path";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bughamster = {
      url = "git+ssh://git@github.com/canonical/bughamster?ref=jira-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-prefetch-github = {
      url = "github:seppeljordan/nix-prefetch-github/v7.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-mine,
    home-manager,
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
          ./npu.nix
          ./nixos.nix
          ./zipzap/nixos.nix
        ];
      };
    };
  };
}
