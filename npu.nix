# vim: et:ts=2:sw=2
{ config, lib, pkgs, flakes, ... }: {
  imports = [
    "${flakes.nixpkgs-unstable}/nixos/modules/hardware/cpu/intel-npu.nix"
  ];

  nixpkgs.overlays = [
    (final: prev: let
      unstable = import flakes.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
      };
    in {
      inherit (unstable) intel-npu-driver;
    })
  ];

  hardware.cpu.intel.npu.enable = true;
}
