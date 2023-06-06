-- vim options
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.relativenumber = false
vim.opt.number = true

vim.opt.listchars = { eol = '↵', space = '·', tab = '>~', nbsp = '␣' }
vim.opt.list = true

-- don't break word when wrapping

vim.opt.ignorecase = true

vim.opt.wrap = true
vim.opt.breakindent = true -- Indent wrapped lines
vim.opt.linebreak = true
vim.opt.lispoptions = { shift = 2 }

vim.opt.scrolloff = 8
vim.opt.swapfile = false

vim.opt.fillchars = { eob = '~' }

vim.g.ackprg = 'ag --vimgrep'

vim.opt.ff = 'unix'
vim.opt.fileformat = 'unix'
