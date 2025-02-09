# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: let
  lua = flakes.lib.nixvim.lua;
in {
  programs.nixvim.plugins.mini = {
    enable = true;
    modules = {
      ai = {
        around = "a";
        inside = "i";
        around_next = "an";
        inside_next = "in";
        around_last = "al";
        inside_last = "il";
      };
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
      starter = {
        items = [
          (lua ''require('mini.starter').sections.builtin_actions()'')
          (lua ''require('mini.starter').sections.recent_files(7)'')
          (lua ''require('mini.starter').sections.telescope()'')
        ];
        evaluate_single = true;
      };
    };

    luaConfig.post = ''
      _M.map('n', '<C-b>', require('mini.files').open, 'MiniFiles: open')
    '';
  };
}
