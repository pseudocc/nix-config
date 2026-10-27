# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    package = pkgs.vimPlugins.copilot-lua.overrideAttrs {
      name = "vimplugin-copilot.lua-3.2.0";
      version = "3.2.0";
      src = pkgs.fetchFromGitHub {
        owner = "zbirenbaum";
        repo = "copilot.lua";
        rev = "82607bbb8528222a9a28bfcab0aceb3a7fed7e85"; # v3.2.0
        hash = "sha256-rTLTToIoleYlkHiaWBG7gvxrFQ5fqVQsMHjDpc31Liw=";
      };
    };
    settings = {
      server.type = "nodejs";
      panel.enabled = false;
      suggestion = {
        enabled = true;
        auto_trigger = true;
        debounce = 100;
        keymap = {
          accept = "<C-Tab>";
          accept_word = "<M-,>";
          accept_line = "<M-.>";
          next = "<M-]>";
          prev = "<M-[>";
          dismiss = "<C-Esc>";
        };
      };
      filetypes.yaml = true;
    };
  };
}
