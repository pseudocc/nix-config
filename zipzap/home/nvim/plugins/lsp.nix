# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  programs.nixvim.plugins.lsp = {
    enable = true;
    autoEnableSources = true;

    keymaps = {
      diagnostics = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };

      lspBuf = {
        K = "hover";
        gd = "definition";
        gD = "references";
        gi = "implementation";
        gt = "type_definition";
      };
    };

    servers = {
      bashls.enable = true;
      clangd.enable = true;
      ts_ls = {
        enable = true;
        settings = {
          root_dir = "root_pattern('package.json', '.git')";
          single_file_support = true;
        };
      };
      zls.enable = true;
      pyright.enable = true;
    };
  };
}
