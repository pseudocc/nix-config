# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim.globals = {
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

  programs.nixvim.opts = {
    expandtab = true;
    tabstop = 2;
    shiftwidth = 0;     # follow tabstop
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

}
