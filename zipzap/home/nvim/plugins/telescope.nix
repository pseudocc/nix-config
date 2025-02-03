# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: let
  lua = flakes.lib.nixvim.lua;
in {
  programs.nixvim.plugins.telescope = {
    enable = true;

    luaConfig.pre = let
      leader = ",";
    in ''
      local Telescope = {
        core = require 'telescope',
        builtin = require 'telescope.builtin',
      }
      Telescope.core.load_extension('git_worktree')
      Telescope.git_worktree = Telescope.core.extensions.git_worktree.git_worktree;
      Telescope.todo = Telescope.core.extensions['todo-comments'].todo;
      function Telescope.map(mode, l, r, desc)
        desc = desc and 'Telescope: ' .. desc
        _M.map(mode, l, r, desc)
      end

      Telescope.map('n', '<C-p>', Telescope.builtin.git_files, 'git_files')
      Telescope.map('n', '<C-s>', Telescope.builtin.live_grep, 'live_grep')
      Telescope.map('n', '${leader}<C-p>', Telescope.builtin.find_files, 'find_files')
      Telescope.map('n', '${leader}<C-r>', Telescope.builtin.lsp_references, 'lsp_references')
      Telescope.map('n', '${leader}${leader}', Telescope.builtin.buffers, 'buffers')
      Telescope.map('n', '${leader}<C-s>', function ()
        local function wrap(value)
          Telescope.builtin.grep_string { search = value }
        end
        vim.ui.input({ prompt = 'Telescope grep > ' }, wrap)
      end, 'grep_string')
      Telescope.map('n', '${leader}<C-g>', Telescope.git_worktree, 'git_worktree')
      Telescope.map('n', '${leader}<C-t>', Telescope.todo, 'todo')
    '';
  };
}
