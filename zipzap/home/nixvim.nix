# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim = let
    colors = flakes.colors;
    join = lib.concatStringsSep;
  in {
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
    };

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
      listchars = join "," [
        "tab:↦ "
        "trail:·"
        "extends:…"
        "precedes:…"
        "nbsp:␣"
      ];
    };

    plugins = {
      mini = {
        enable = true;
        modules = {
          ai = {};
          files = {
            mappings = {
              close = "q";
              go_in = "l";
              go_in_plus = "L";
              go_out = "h";
              go_out_plus = "H";
              mark_goto = "'";
              mark_set = "m";
              reset = "<BS>";
              reveal_cwd = "@";
              show_help = "?";
              synchronize = "=";
              trim_left = "<";
              trim_right = ">";
            };
            windows.preview = true;
          };
          jump2d = {
            mappings.start_jumping = "<CR>";
            labels = "aoeuhtnspidcr,";
          };
          move = {
            mappings = {
              left = "<M-h>";
              right = "<M-l>";
              down = "<M-j>";
              up = "<M-k>";
              line_left = "<M-h>";
              line_right = "<M-l>";
              line_down = "<M-j>";
              line_up = "<M-k>";
            };
            options.reindent_linewise = false;
          };
          splitjoin = {
            mappings.toggle = "gS";
          };
          cursorword = {};
        };
      };

    };

    highlight = with colors; {
      ExtraWhitespace.bg = "#${bright.black}";
    };

    match = {
      ExtraWhitespace = "\\s\\+$";
    };

    diagnostics = {
      virtual_lines.only_current_line = true;
      virtual_text = true;
    };

    filetype = {
      extension = {
        pxu = "pxu";
      };
    };
  };
}
