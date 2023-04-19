require("tcreach.remap")

if vim.g.vscode then
   vim.cmd('colorscheme shine') 
else
end

vim.opt.listchars = {eol = '↵', space = '·', tab = '>~' }
vim.opt.list = true

vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.autoread = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 8

