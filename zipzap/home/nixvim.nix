# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: let
  lua = flakes.lib.nixvim.lua;
  colors = flakes.colors;
in {
  imports = [
    flakes.nixvim.homeManagerModules.nixvim
    ./nvim/plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    nixpkgs.useGlobalPackages = true;
    withPython3 = false;
    withRuby = false;

    colorscheme = "catppuccin";
    colorschemes.catppuccin = {
      enable = true;
      settings = {
        term_colors = true;
        transparent_background = true;
      };
    };

    globals = {
      mapleader = " ";
      python_indent = {
        disable_parentheses_indenting = false;
        closed_paren_align_last_line = false;
        searchpair_timeout = 150;
        continue = "shiftwidth()";
        open_paren = "shiftwidth()";
        nested_paren = "shiftwidth()";
      };
    };

    autoCmd = [
      # Always jump to the last known cursor position
      {
        event = ["BufReadPost"];
        pattern = ["*"];
        callback = lua ''function ()
          if vim.bo.ft == "commit" then return end
          local line = vim.fn.line([['"]])
          local last = vim.fn.line("$")
          if line >= 1 and line <= last then
            vim.cmd([[normal! g`"]])
          end
        end'';
      }
    ];

    opts = {
      expandtab = true;
      tabstop = 2;
      shiftwidth = 0;           # follow tabstop
      softtabstop = 8;
      smarttab = true;
      smartindent = true;
      autoindent = true;

      mouse = "";
      termguicolors = true;

      hidden = true;
      swapfile = false;
      modeline = true;
      cursorline = true;

      number = true;
      relativenumber = true;
      wrap = true;
      signcolumn = "yes:1";

      list = true;
      listchars = lib.concatStringsSep "," [
        "tab:↦ "
        "trail:·"
        "extends:…"
        "precedes:…"
        "nbsp:␣"
      ];
    };

    diagnostics = {
      virtual_lines.only_current_line = true;
      virtual_text = true;
    };

    filetype.extension = {
      pxu = "pxu";
    };
  };
}
