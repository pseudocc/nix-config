Harpoon = {
  core = require('harpoon'),
  leader = '<leader>',
}

function Harpoon:map(mode, l, r, desc)
  desc = desc and 'Harpoon: ' .. desc
  M.map(mode, self.leader .. l, r, desc)
end

function Harpoon.list(fname, ...)
  local args = {...}
  return function ()
    local list = Harpoon.core:list()
    return list[fname](list, unpack(args))
  end
end

function Harpoon.telescope()
  local conf = require "telescope.config".values
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"

  local files = Harpoon.core:list()
  local file_paths = {}
  for _, item in ipairs(files.items) do
    table.insert(file_paths, item.value)
  end

  pickers.new({}, {
    prompt_title = "Harpoon",
    finder = finders.new_table { results = file_paths },
    previewer = conf.file_previewer {},
    sorter = conf.generic_sorter {},
  }):find()
end

function Harpoon:setup()
  self.core.setup {}

  Harpoon:map('n', 'ma', Harpoon.list('add'), 'Add file')
  Harpoon:map('n', 'mr', Harpoon.list('remove'), 'Remove file')
  Harpoon:map('n', '(', Harpoon.list('prev'), 'Previous')
  Harpoon:map('n', ')', Harpoon.list('next'), 'Next')

  for i = 1, 6 do
    Harpoon:map('n', tostring(i), Harpoon.list('select', i), 'Select ' .. i)
  end

  Harpoon:map('n', '~', Harpoon.telescope, 'Telescope')
end

Harpoon:setup()
