# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.neovim = let
    mapleader = {
      global = " ";
      plugin = ",";
    };
  in {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython3 = false;
    withRuby = false;

    extraLuaConfig = let
      require = builtins.readFile;
    in ''
      local g = vim.g
      g.mapleader = '${mapleader.global}'

      ${require ./nvim/opts.lua}
      ${require ./nvim/maps.lua}
    '';

    extraConfig = ''
      " When editing a file, always jump to the last known cursor position.
      autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif
    '';

    plugins = with pkgs.vimPlugins; let
      lua = code: "\nlua << EOF\n${code}\nEOF\n";
      importLua = file: lua (
        "vim.g.mapleader = '${mapleader.plugin}'\n"
        + builtins.readFile file
      );
    in [
      vim-fugitive

      {
        plugin = lualine-nvim;
        config = lua ''
          require('lualine').setup {
            options = { theme = 'catppuccin' }
          }
        '';
      }

      {
        plugin = nvim-autopairs;
        config = importLua ./nvim/plugin/autopairs.lua;
      }

      {
        plugin = nvim-surround;
        config = lua ''require('nvim-surround').setup{}'';
      }

      {
        plugin = indent-blankline-nvim;
        config = lua ''
          require('ibl').setup {
            indent = {
              char = { "", '┃', }
            },
            scope = {
              show_end = false;
              show_start = false;
            },
          }
        '';
      }

      {
        plugin = harpoon2;
        config = importLua ./nvim/plugin/harpoon.lua;
      }

      {
        plugin = telescope-nvim;
        config = importLua ./nvim/plugin/telescope.lua;
      }

      {
        plugin = todo-comments-nvim;
        config = importLua ./nvim/plugin/todo-comments.lua;
      }

      git-worktree-nvim
      telescope-file-browser-nvim

      {
        plugin = gitsigns-nvim;
        config = importLua ./nvim/plugin/gitsigns.lua;
      }

      {
        plugin = copilot-lua;
        config = "autocmd InsertEnter ++once silent! Copilot"
          + importLua ./nvim/plugin/copilot.lua;
      }
    ];
  };
}
