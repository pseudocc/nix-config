local todo = require 'todo-comments'
todo.setup {}

local function map(mode, l, r, desc)
  local opts = {
    silent = true,
    remap = false,
    desc = 'todo-comments: '.. desc,
  }
  vim.keymap.set(mode, l, r, opts)
end

map('n', ']t', todo.jump_next, 'next')
map('n', '[t', todo.jump_prev, "previous")
