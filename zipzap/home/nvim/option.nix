# vim: et:ts=2:sw=2
{ lib, ... }: {
  programs.nixvim.globals = {
    mapleader = " ";
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

    updatetime = 500;
  };
}
