vim.g.mapleader = ","

vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")
vim.keymap.set("n", "<C-k>", "<C-W>k")

vim.keymap.set("n", "//", ":nohlsearch<CR>")

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<Up>", "<Nop>")
vim.keymap.set("n", "<Down>", "<Nop>")
vim.keymap.set("n", "<Left>", "<Nop>")
vim.keymap.set("n", "<Right>", "<Nop>")

vim.keymap.set("n", "-", "[[<Cmd>call VSCodeNotify('git.openFile')<CR>]]")
vim.keymap.set("n", "+", "[[<Cmd>call VSCodeNotify('git.openChange')<CR>]]")

vim.keymap.set(
    'n',
    '<leader>t',
    [[<Cmd>call VSCodeNotify('workbench.view.explorer')<CR>]]
)

vim.keymap.set(
    'n',
    '<leader>g',
    [[<Cmd>call VSCodeNotify('workbench.view.scm')<CR>]]
)


vim.keymap.set(
    'n',
    'cc',
    [[<Cmd>call VSCodeNotify('git.commitStaged')<CR>]]
)

