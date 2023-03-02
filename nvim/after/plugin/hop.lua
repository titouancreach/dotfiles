local hop = require('hop')
local directions = require('hop.hint').HintDirection

vim.keymap.set('', 'f', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', 'F', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true })
end, {remap=true})

vim.keymap.set('', 't', function()
  hop.hint_char1({ direction = directions.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })
end, {remap=true})

vim.keymap.set('', 'T', function()
  hop.hint_char1({ direction = directions.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })
end, {remap=true})

vim.keymap.set('n', 's', function()
  hop.hint_char2({ direction = directions.after_cursor })
end, { remap = true })

vim.keymap.set('n', 'S', function()
  hop.hint_char2({ direction = directions.BEFORE_CURSOR })
end, { remap = true })

vim.keymap.set('v', 'x', function()
  hop.hint_char2({ direction = directions.after_cursor })
end, { remap = true })

vim.keymap.set('v', 'X', function()
  hop.hint_char2({ direction = directions.BEFORE_CURSOR })
end, { remap = true })




