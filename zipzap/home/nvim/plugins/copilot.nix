# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim.plugins.copilot-lua = {
    enable = true;
    package = pkgs.unstable.vimPlugins.copilot-lua;
    settings = {
      server = {
        type = "binary";
        custom_server_filepath = lib.getExe pkgs.unstable.copilot-language-server;
      };
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

  programs.nixvim.extraPlugins = [
    pkgs.unstable.vimPlugins.copilot-lsp
  ];
}
