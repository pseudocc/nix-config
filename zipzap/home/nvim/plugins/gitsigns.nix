# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  programs.nixvim.plugins.gitsigns = {
    enable = true;
    settings = {
      signcolumn = false;
      numhl = true;
      on_attach = let
        leader = ",";
      in flakes.lib.nixvim.lua ''function (bufnr)
        local this = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          if opts.desc then
            opts.desc = 'Gitsigns: ' .. opts.desc
          end
          _M.map(mode, l, r, opts)
        end

        for key, action in pairs {
          ['[c'] = { this.prev_hunk, 'previous hunk' },
          [']c'] = { this.next_hunk, 'next hunk' },
        } do
          map('n', key, function ()
            if vim.wo.diff then return key end
            vim.schedule(action[1])
            return '<ignore>'
          end, { expr = true, desc = action[2] })
        end

        for key, action in pairs {
          ['${leader}hs'] = { this.stage_hunk, 'stage hunk' },
          ['${leader}hr'] = { this.reset_hunk, 'reset hunk' },
        } do
          map({'n', 'v'}, key, action[1], action[2])
        end

        for key, action in pairs {
          ['${leader}hu'] = { this.undo_stage_hunk, 'undo stage hunk' },
          ['${leader}hp'] = { this.preview_hunk, 'preview hunk' },
          ['${leader}hb'] = { this.toggle_current_line_blame, 'toggle blame' },
          ['${leader}hd'] = { this.diffthis, 'diff this' },
        } do
          map('n', key, action[1], action[2])
        end

        map({'o', 'x'}, 'ih', this.select_hunk, 'select hunk')
      end'';
    };
  };


  home.packages = [ pkgs.tree-sitter ];
}
