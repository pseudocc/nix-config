# vim: et:ts=2:sw=2
{ lib, flakes, ... }: {
  programs.nixvim.keymaps = let
    lua = flakes.lib.nixvim.lua;
    innerMap = options: mode: key: action: {
      inherit mode options key action;
    };
    keymap = desc: innerMap { silent = true; desc = desc; };
  in [
    (keymap "rnu: toggle" "n" "<leader>tr" ":set rnu!<CR>")
    (keymap "edit: insert a real <Tab>" "i" "<S-Tab>" "<C-V><Tab>")
    (keymap "edit: blackhole delete" "v" "<leader>D" ''"_d'')
    (keymap "edit: blackhole paste" "v" "<leader>P" ''"_dP'')
    (keymap "edit: copy to clipboard" "v" "Y" ''"+y'')
    (keymap "edit: select all" "n" "gV" ''ggVG'')
    (keymap "edit: sudo write" "n" "<leader>W" ":w !sudo tee % > /dev/null<CR>")
    (keymap "terminal: normal mode" "t" "<C-D>" "<C-\\><C-N>")
    (keymap "buffer: previous" "n" "[b" ":bprev<CR>")
    (keymap "buffer: next" "n" "]b" ":bnext<CR>")
  ];
}
