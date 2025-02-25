# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    settings = {
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
