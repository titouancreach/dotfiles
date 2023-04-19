vim.g.mapleader = ","

vim.keymap.set("n", "<C-j>", "<C-W>j")
vim.keymap.set("n", "<C-h>", "<C-W>h")
vim.keymap.set("n", "<C-l>", "<C-W>l")
vim.keymap.set("n", "<C-k>", "<C-W>k")

vim.keymap.set("n", "//", ":nohlsearch<CR>")

vim.keymap.set('n', 'k', "gk")
vim.keymap.set('n', 'j', "gj")


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

vim.keymap.set(
    'n',
    '<leader>w',
    [[<Cmd>call VSCodeNotify('workbench.action.switchWindow')<CR>]]
)

vim.keymap.set(
    'n',
    '<leader>co', -- copen
    [[<Cmd>call VSCodeNotify('workbench.action.problems.focus')<CR>]]
)

vim.keymap.set(
    'n',
    '<leader>cp', -- cprev
    [[<Cmd>call VSCodeNotify('editor.action.marker.prev')<CR>]]
)

vim.keymap.set(
    'n',
    '<leader>cn', -- cnext
    [[<Cmd>call VSCodeNotify('editor.action.marker.next')<CR>]]
)
