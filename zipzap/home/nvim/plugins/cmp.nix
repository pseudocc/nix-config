# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  programs.nixvim.plugins.cmp = {
    enable = true;
    autoEnableSources = true;

    settings.sources = [
      { name = "nvim_lsp"; }
      { name = "path"; }
      { name = "buffer"; }
      { name = "luasnip"; }
    ];

    settings.mapping = {
      "<C-Space>" = "cmp.mapping.complete()";
      "<C-p>" = "cmp.mapping.select_prev_item()";
      "<C-n>" = "cmp.mapping.select_next_item()";
      "<C-y>" = "cmp.mapping.confirm()";
      "<C-Esc>" = "cmp.mapping.close()";
      "<C-Up>" = "cmp.mapping.scroll_docs(-4)";
      "<C-Down>" = "cmp.mapping.scroll_docs(4)";
    };

    settings.snippet.expand = ''function (args)
      require('luasnip').lsp_expand(args.body)
    end'';
  };

  programs.nixvim.plugins = {
    luasnip.enable = true;
  };
}
