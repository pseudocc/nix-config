# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [
    ./mini.nix
    ./fugit2.nix
    ./treesitter.nix
    ./telescope.nix
    ./gitsigns.nix
    ./copilot.nix
    ./cmp.nix
    ./lsp.nix
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
        indent = {
          char = "┃";
          tab_char = "┇";
        };
        scope = {
          show_end = false;
          show_start = false;
        };
      };
    };

    # telescope extension is set in telescope.nix
    git-worktree.enable = true;

    # telescope extension is set in telescope.nix
    todo-comments = {
      enable = true;
      luaConfig.post = ''
        Todo = require 'todo-comments'
        _M.map('n', '[t', Todo.jump_prev, 'Todo: previous')
        _M.map('n', ']t', Todo.jump_next, 'Todo: next')
      '';
    };

    image = {
      enable = true;
      settings.backend = "kitty";
    };
  };

  programs.nixvim = {
    extraPackages = with pkgs; [
      kitty
      imagemagick
    ];
    extraLuaPackages = luaPkgs: [ luaPkgs.magick ];
    extraPlugins = [ pkgs.vimPlugins.harpoon2 ];
    extraConfigLua = builtins.readFile ./harpoon.lua;
  };
}
