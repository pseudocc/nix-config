# vim: et:ts=2:sw=2
{ ... }: {
  programs.nixvim.filetype = {
    extension = {
      pxu = "pxu";
    };
  };

  programs.nixvim.extraFiles = {
    "after/ftplugin/c.lua".text = ''
      vim.opt_local.tabstop = 8
      vim.opt_local.expandtab = false
    '';

    "after/ftplugin/python.lua".text = ''
      vim.opt_local.tabstop = 4
      vim.g.python_indent = {
        disable_parentheses_indenting = false,
        closed_paren_align_last_line = false,
        searchpair_timeout = 150,
        continue = "shiftwidth()",
        open_paren = "shiftwidth()",
        nested_paren = "shiftwidth()",
      }
    '';

    "after/ftplugin/make.lua".text = ''
      vim.opt_local.tabstop = 4
      vim.opt_local.expandtab = false
    '';

    "after/ftplugin/sh.lua".text = ''
      vim.opt_local.tabstop = 4
    '';
  };
}

