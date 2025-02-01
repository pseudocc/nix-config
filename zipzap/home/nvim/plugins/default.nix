# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ./mini.nix
    ./fugit2.nix
  ];

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        term_colors = true;
        transparent_background = true;
      };
    };

    lualine = {
      enable = true;
      settings.options = {
        theme = "catppuccin";
      };
    };
  };
}
