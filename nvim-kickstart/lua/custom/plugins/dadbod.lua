-- Database UI (vim-dadbod); completion is wired into blink.cmp in init.lua
-- (sources.per_filetype sql/mysql/plsql)

-- Must be set before the plugins load
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1

vim.pack.add {
  'https://github.com/tpope/vim-dadbod',
  'https://github.com/kristijanhusak/vim-dadbod-ui',
  'https://github.com/kristijanhusak/vim-dadbod-completion',
}

vim.keymap.set('n', '<leader>db', '<cmd>DBUIToggle<CR>', { desc = '[D]ata[b]ase UI' })
