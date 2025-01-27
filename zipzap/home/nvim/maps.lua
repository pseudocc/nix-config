-- vim: et:ts=2:sw=2

local function map(mode, l, r, desc)
  local opts = {
    silent = true,
    remap = false,
    desc = desc,
  }
  vim.keymap.set(mode, l, r, opts)
end

-- toggle relative number
map('n', '<leader>tr', [[:set rnu!<CR>]])

-- most important remaps
map('i', '<S-Tab>', [[<C-V><Tab>]], 'Insert a real <Tab>')
map('v', '<leader>D', [["_d]], 'Blackhole delete')
map('v', '<leader>P', [["_dP]], 'Blackhole paste')
map('v', 'c', [["+y]], 'Copy to system clipboard')
map('n', 'gV', [[ggVG]], 'Select all')

-- move lines up/down or character left/right
map('n', '<M-k>', [[:m .-2<CR>==]], 'move: line up')
map('n', '<M-j>', [[:m .+1<CR>==]], 'move: line down')
map('n', '<M-l>', [["9x"9p]], 'move: character right')
map('n', '<M-h>', [[h"9x"9ph]], 'move: character left')
map('i', '<M-k>', [[<Esc>:m .-2<CR>==gi]], 'move: line up')
map('i', '<M-j>', [[<Esc>:m .+1<CR>==gi]], 'move: line down')
map('i', '<M-l>', [[<Esc>l"9x"9pi]], 'move: character right')
map('i', '<M-h>', [[<Esc>"9x"9phi]], 'move: character left')
map('v', '<M-k>', [[:m '<-2<CR>gv=gv]], 'move: line up')
map('v', '<M-j>', [[:m '>+1<CR>gv=gv]], 'move: line down')

-- misc
map('n', '<leader>f', vim.lsp.buf.format, "LSP: format buffer")
map('n', '<leader>W', [[:w !sudo tee % > /dev/null<CR>]], 'SUDO: write file')
map('t', '<C-D>', [[<C-\><C-N>]], 'Exit terminal mode')

-- buffer navigations
map('n', '[b', vim.cmd.bprevious, 'Buffer: previous')
map('n', ']b', vim.cmd.bnext, 'Buffer: next')

