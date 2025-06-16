# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: let
  lua = flakes.lib.nixvim.lua;
  colors = flakes.colors;
in {
  imports = [
    flakes.nixvim.homeManagerModules.nixvim
    ./nvim/plugins
    ./nvim/highlight.nix
    ./nvim/option.nix
    ./nvim/filetype.nix
    ./nvim/keymap.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    nixpkgs.useGlobalPackages = true;
    withPython3 = false;
    withRuby = false;

    extraConfigLuaPre = ''
      function _M.map(mode, key, cmd, opts)
        if type(opts) == "string" then
          opts = { desc = opts }
        else
          opts = opts or {}
        end
        if opts.noremap == nil then opts.noremap = true end
        if opts.silent == nil then opts.silent = true end
        vim.keymap.set(mode, key, cmd, opts)
      end

      function _M.wrapVimCmd(cmd)
        return function()
          vim.cmd(cmd)
        end
      end

      function _M.capitalize(word)
        return word:sub(1,1):upper() .. word:sub(2):lower()
      end

      function _M.toggleVirtualText()
        local cfg = vim.diagnostic.config()
        vim.diagnostic.config({ virtual_text = not cfg.virtual_text })
      end
    '';

    extraConfigLuaPost = ''
      _M.map('n', '<leader>vt', _M.toggleVirtualText, 'diagnostic: toggle virtual text')

      local lualine_cfg = require 'lualine.components.diagnostics.config'
      for type, icon in pairs(lualine_cfg.symbols.icons) do
        local hl = 'DiagnosticSign' .. _M.capitalize(type)
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    '';

    autoCmd = [
      # Always jump to the last known cursor position
      {
        event = ["BufReadPost"];
        pattern = ["*"];
        callback = lua ''function ()
          if vim.bo.ft == "commit" then return end
          local line = vim.fn.line([['"]])
          local last = vim.fn.line("$")
          if line >= 1 and line <= last then
            vim.cmd([[normal! g`"]])
          end
        end'';
      }
    ];

    diagnostic.settings = {
      virtual_lines.current_line = true;
      virtual_text = false;
    };

    dependencies.nodejs.package = pkgs.nodejs;
  };
}
