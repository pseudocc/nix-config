# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ./mini.nix
    ./fugit2.nix
  ];

  programs.nixvim.colorscheme = "catppuccin";
  programs.nixvim.colorschemes.catppuccin = {
    enable = true;
    settings = {
      term_colors = true;
      transparent_background = true;
    };
  };

  programs.nixvim.plugins = {
    web-devicons.enable = true;

    lualine = {
      enable = true;
      settings.options = {
        theme = "catppuccin";
      };
    };

    nvim-autopairs = {
      enable = true;
      luaConfig.post = builtins.readFile ./nvim-autopairs.lua;
    };
  };
}
