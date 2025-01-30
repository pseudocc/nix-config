# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim = let
    colors = flakes.colors;
    join = lib.concatStringsSep;
  in {
    enable = true;
    defaultEditor = true;
    type = "lua";

    viAlias = true;
    vimAlias = true;

    nixpkgs.useGlobalPackages = true;
    withPython3 = false;
    withRuby = false;

    diagnostics = {
      virtual_lines.only_current_line = true;
      virtual_text = true;
    };

    filetype = {
      extension = {
        pxu = "pxu";
      };
    };

    globals = {
      mapleader = " ";
    };

    highlight = with colors; {
      ExtraWhitespace.bg = "#${highlight-low}";
    };

    match = {
      ExtraWhitespace = "\\s\\+$";
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
  };
}
