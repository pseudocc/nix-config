# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ./mini.nix
    ./fugit2.nix
    ./treesitter.nix
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

    nvim-surround.enable = true;

    nvim-autopairs = {
      enable = true;
      luaConfig.post = builtins.readFile ./nvim-autopairs.lua;
    };

    indent-blankline = {
      enable = true;
      settings = {
        indent.char = "┃";
        scope = {
          show_end = false;
          show_start = false;
        };
      };
    };
  };

  programs.nixvim.extraPlugins = [ pkgs.vimPlugins.harpoon2 ];
  programs.nixvim.extraConfigLua = builtins.readFile ./harpoon.lua;
}
