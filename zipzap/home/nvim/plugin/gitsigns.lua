local function on_attach (bufnr)
  local gs = package.loaded.gitsigns
  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.silent = true
    opts.remap = false
    opts.buffer = bufnr
    vim.keymap.set(mode, l, r, opts)
  end

  map('n', '[c', function ()
    if vim.wo.diff then return '[c' end
    vim.schedule(gs.prev_hunk)
    return '<ignore>'
  end, { expr = true })

  map('n', 'c]', function ()
    if vim.wo.diff then return 'c]' end
    vim.schedule(gs.next_hunk)
    return '<ignore>'
  end, { expr = true })

  -- Actions
  map({ 'n', 'v' }, '<leader>hs', [[:Gitsigns stage_hunk<CR>]])
  map({ 'n', 'v' }, '<leader>hr', [[:Gitsigns reset_hunk<CR>]])
  map('n', '<leader>hu', gs.undo_stage_hunk)
  map('n', '<leader>hp', gs.preview_hunk)
  map('n', '<leader>tb', gs.toggle_current_line_blame)
  map('n', '<leader>hd', gs.diffthis)

  -- Motion
  map({'o', 'x'}, 'ih', [[:<C-U>Gitsigns select_hunk<CR>]])
end

require('gitsigns').setup {
  signcolumn = false,
  numhl = true,
  on_attach = on_attach,
}
