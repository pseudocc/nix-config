# vim: et:ts=2:sw=2
{
  description = "pseudoc";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Ghostty Terminal (Customized)
    ghostty.url = "github:pseudocc/ghostty";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs:
  let
    flakes = inputs // {
      me = rec {
        nick = "pseudoc";
        user = nick;
        name = "Atlas Yu";
        email = "${nick}@163.com";
        signingKey = "BEA76B7637CEBC8A";
        description = "Real Vim enthusiast & Rust hater.";
      };

      colors = {
        background = "#272120";
        foreground = "#ddbfb9";
        cursor = "#ffafa2";
    
        black = "#413736";
        red = "#db475f";
        green = "#6ead47";
        yellow = "#c68c2e";
        blue = "#5a9bec";
        magenta = "#c36ee7";
        cyan = "#33acac";
        white = "#cfc4c2";
    
        bright = {
          black = "#756764";
          red = "#ed6677";
          green = "#7fc453";
          yellow = "#dfa13e";
          blue = "#7cb1f5";
          magenta = "#d18fef";
          cyan = "#3dc4c4";
          white = "#f8f6f6";
        };
      };
    };
  in {
    nixosConfigurations = {
      zipzap = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit flakes; };
        system = "x86_64-linux";
        modules = [
          ./nixos.nix
          ./zipzap/nixos.nix
        ];
      };
    };
  };
}
