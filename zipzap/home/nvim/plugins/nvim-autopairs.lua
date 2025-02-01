NvimAutopairs = {
  core = require('nvim-autopairs'),
  cond = require('nvim-autopairs.conds'),
  Rule = require('nvim-autopairs.rule'),
}

-- Add spaces between parentheses
-- Reference: https://github.com/windwp/nvim-autopairs/wiki/Custom-rules#add-spaces-between-parentheses
-- +--------+--------+-------+
-- | Before | Insert | After |
-- +--------+--------+-------+
-- | (|)    |  <WS>  | ( | ) |
-- | ( | )  |  )     | (  )| |
-- +--------+--------+-------+
function NvimAutopairs:setup(...)
  local brackets = {...}
  self.core.add_rules {
    self.Rule(' ', ' ')
      :with_pair(function(opts)
        local pair = opts.line:sub(opts.col - 1, opts.col)
        for _, bracket in pairs(brackets) do
          if vim.tbl_contains({bracket[1] .. bracket[2]}, pair) then
            return true
          end
        end
        return false
      end)
      :with_move(self.cond.none())
      :with_cr(self.cond.none())
      :with_del(function(opts)
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local context = opts.line:sub(col - 1, col + 2)
        for _, bracket in pairs(brackets) do
          if vim.tbl_contains({bracket[1] .. '  ' .. bracket[2]}, context) then
            return true
          end
        end
        return false
      end)
  }

  for _, bracket in pairs(brackets) do
    self.core.add_rules {
      self.Rule(bracket[1] .. ' ', ' ' .. bracket[2])
        :with_pair(self.cond.none())
        :with_move(function(opts) return opts.char == bracket[2] end)
        :with_del(self.cond.none())
        :use_key(bracket[2])
        :replace_map_cr(function(_) return '<C-c>2xi<CR><C-c>O' end)
    }
  end
end

NvimAutopairs:setup({'(', ')'}, {'[', ']'}, {'{', '}'})
