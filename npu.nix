# vim: et:ts=2:sw=2
{ config, lib, pkgs, flakes, ... }: {
  imports = [
    "${flakes.nixpkgs-mine}/nixos/modules/hardware/cpu/intel-npu.nix"
  ];

  nixpkgs.overlays = [
    (final: prev: let
      mine = import flakes.nixpkgs-mine {
        inherit (pkgs) system;
      };
    in {
      inherit (mine) intel-npu-driver intel-npu-firmware;
    })
  ];

  hardware.cpu.intel.npu.enable = true;
}
