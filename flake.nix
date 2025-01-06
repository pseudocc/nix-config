{
  description = "pseudoc";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Ghostty terminal
    ghostty = {
      url = "github:pseudocc/ghostty";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    constants = import ./constants.nix;
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      zipzap = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs constants;};
        # > Our main nixos configuration file <
        modules = [
          ./nixos.nix
          ./zipzap/system.nix
        ];
      };
    };
  };
}
