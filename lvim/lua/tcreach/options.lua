-- vim options
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.relativenumber = false
vim.opt.number = true


-- don't break word when wrapping
vim.opt.ignorecase = true

vim.opt.wrap = true
vim.opt.breakindent = true -- Indent wrapped lines
vim.opt.breakindentopt = { 'shift:4' }

vim.opt.linebreak = true

vim.opt.scrolloff = 8
vim.opt.swapfile = false

vim.opt.fillchars = { eob = '~', fold = ' ' , foldopen= '', foldsep = ' ' ,foldclose = '' }

vim.g.ackprg = 'rg --vimgrep --smart-case'

vim.opt.ff = 'unix'
vim.opt.fileformat = 'unix'

vim.opt.autoread = true

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
