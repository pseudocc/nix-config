# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  programs.nixvim.plugins.lsp = let
    leader = ",";
  in {
    enable = true;

    keymaps = {
      diagnostic = {
        "[d" = "goto_prev";
        "]d" = "goto_next";
      };

      lspBuf = {
        K = "hover";
        gd = "definition";
        gD = "references";
        gi = "implementation";
        gt = "type_definition";
        "${leader}rn" = "rename";
        "${leader}ca" = "code_action";
        "${leader}f" = "format";

        "<C-k>" = {
          mode = [ "n" "i" "v" "x" ];
          action = "signature_help";
        };
      };
    };

    onAttach = ''
      vim.api.nvim_create_autocmd('CursorHold', {
        buffer = bufnr,
        callback = function()
          local opts = {
            focusable = false,
            close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
          }
          vim.diagnostic.open_float(nil, opts)
        end
      })
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
