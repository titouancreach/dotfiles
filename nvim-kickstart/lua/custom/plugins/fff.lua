-- fff.nvim: frecency-ranked file finder with a Rust backend.
-- The binary is downloaded/built by the PackChanged hook in init.lua.
-- Loaded at startup so frecency tracking sees every file you open.
vim.pack.add { 'https://github.com/dmtrKovalenko/fff.nvim' }

require('fff').setup {}

-- Replaces Telescope's git_files file finder.
vim.keymap.set('n', '<leader>sf', function()
  require('fff').find_files()
end, { desc = '[S]earch [F]iles (fff)' })
-- Replaces Telescope's live_grep.
vim.keymap.set('n', '<leader>/', function()
  require('fff').live_grep()
end, { desc = '[S]earch by Grep (fff)' })
