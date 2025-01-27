local copilot = require('copilot')

copilot.setup {
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    debounce = 75,
    keymap = {
      accept = false,
      accept_word = '<M-,>',
      accept_line = '<M-.>',
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    TelescopePrompt = false,
    yaml = true,
  },
}

local keymap_accept = '<C-Tab>'
local keycode = vim.api.nvim_replace_termcodes(keymap_accept, true, false, true)
local suggestion = require('copilot.suggestion')
local function accept()
  if suggestion.is_visible() then
    suggestion.accept()
  else
    vim.api.nvim_feedkeys(keycode, 'n', false)
  end
end
vim.keymap.set('i', keymap_accept, accept, { remap = false, silent = true })
