# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.nixvim.plugins.lsp = let
    leader = ",";
    lua = flakes.lib.nixvim.lua;
  in {
    enable = true;

    keymaps = {
      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };

      lspBuf = {
        "${leader}rn" = "rename";
        "${leader}ca" = "code_action";
        "${leader}f" = "format";
      };

      extra = [
        {
          action = lua ''require('telescope.builtin').lsp_definitions'';
          key = "gd";
        }
        {
          action = lua ''require('telescope.builtin').lsp_references'';
          key = "gr";
        }
        {
          action = lua ''require('telescope.builtin').lsp_implementations'';
          key = "gi";
        }
        {
          action = lua ''require('telescope.builtin').lsp_type_definitions'';
          key = "gt";
        }
        {
          action = lua ''
            function ()
              vim.lsp.buf.hover(Lsp.style)
            end
          '';
          key = "K";
        }
        {
          action = lua ''
            function ()
              vim.lsp.buf.signature_help(Lsp.style)
            end
          '';
          key = "<C-k>";
          mode = [ "n" "i" "v" "x" ];
        }
      ];
    };

    luaConfig.pre = ''
      local Lsp = {}
      Lsp.style = {
        border = 'single',
        max_width = 60,
        max_height = 15,
      }
      vim.g.zig_fmt_parse_errors = 0
    '';

    servers = {
      bashls.enable = true;
      clangd.enable = true;
      ts_ls.enable = true;
      zls.enable = true;
      pyright.enable = true;
    };
  };
}
