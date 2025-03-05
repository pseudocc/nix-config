# vim: et:ts=2:sw=2
{ config, lib, pkgs, flakes, ... }: {
  imports = [
    "${flakes.nixpkgs-mine}/nixos/modules/hardware/cpu/intel-npu.nix"
  ];

  hardware.cpu.intel.npu.enable = true;
}
