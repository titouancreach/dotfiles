-- Edit the filesystem like a buffer (icons come from mini.icons, set up in init.lua)
vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup()
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
