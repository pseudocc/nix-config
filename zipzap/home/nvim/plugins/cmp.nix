# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
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

    settings.window = let
      base = {
        border = "single";
        side_padding = 1;
        col_offset = 0;
        zindex = 1001;
        scrollbar = true;
        scroffoff = 0;
        winhighlight = lib.concatStringsSep "," [
          "Normal:Normal"
          "FloatBorder:FloatBorder"
          "CursorLine:Visual"
          "Search:None"
        ];
      };
      mkWindow = overlay: base // overlay;
    in {
      completion = mkWindow {
        max_height = 15;
        max_width = 40;
      };
      documentation = mkWindow {
        max_height = 15;
        max_width = 60;
        zindex = 1002;
      };
    };

    settings.formatting.fields = [
      "abbr"
      "menu"
      "kind"
    ];
    settings.formatting.format = let
      label = {
        max = "20";
        min = "5";
      };
      menu = {
        min = "0";
        max = "10";
      };
      ellipsis = "…";
    in ''
      function (entry, item)
        local function truncate(str, min, max)
          str = str or ""
          if #str > max then
            return str:sub(0, max) .. "${ellipsis}"
          elseif #str < min then
            return str .. string.rep(" ", min - #str)
          end
          return str
        end
        item.menu = truncate(item.menu, ${menu.min}, ${menu.max})
        item.abbr = truncate(item.abbr, ${label.min}, ${label.max})
        return item
      end
    '';

    settings.snippet.expand = ''function (args)
      require('luasnip').lsp_expand(args.body)
    end'';
  };

  programs.nixvim.plugins = {
    luasnip.enable = true;
  };
}
