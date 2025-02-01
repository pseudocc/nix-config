# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ./mini.nix
    ./fugit2.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;
  };
}
