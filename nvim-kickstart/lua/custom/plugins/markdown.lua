-- Pretty in-buffer markdown rendering (uses treesitter + mini from init.lua)
vim.pack.add { 'https://github.com/MeanderingProgrammer/render-markdown.nvim' }

---@diagnostic disable-next-line: missing-fields
require('render-markdown').setup {}
