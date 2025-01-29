local core = require 'telescope'
local builtin = require 'telescope.builtin'

local function map(mode, l, r, desc)
  local opts = {
    silent = true,
    remap = false,
    desc = desc,
  }
  vim.keymap.set(mode, l, r, opts)
end

map('n', '<C-p>', builtin.git_files)
map('n', '<C-s>', builtin.live_grep)
map('n', '<leader><C-p>', builtin.find_files)
map('n', '<leader><C-r>', builtin.lsp_references)
map('n', '<leader><leader>', builtin.buffers)
map('n', '<leader><C-s>', function ()
  local opt = { prompt = 'Telescope grep > ' }
  vim.ui.input(opt, function (value)
    builtin.grep_string { search = value }
  end)
end)

core.setup {
  extensions = {
    file_browser = { hijack_netrw = true, },
  },
}

for name, maps in pairs({
  ['git_worktree'] = {
    ['<leader><C-g>'] = 'git_worktrees',
  },
  ['todo-comments'] = {
    ['<leader><C-t>'] = 'todo',
  },
  ['file_browser'] = {
    ['<C-b>'] = 'file_browser',
  },
}) do
  core.load_extension(name)
  extension = core.extensions[name]
  for key, fname in pairs(maps) do
    map('n', key, extension[fname])
  end
end
