-- Show marks in the sign column + mark management helpers
vim.pack.add { 'https://github.com/chentoast/marks.nvim' }

require('marks').setup {}

vim.keymap.set('n', '<leader>sm', function()
  require('telescope.builtin').marks()
end, { desc = '[S]earch [M]arks' })

-- Send marks to the quickfix list for :cnext/:cprev navigation
vim.keymap.set('n', '<leader>mq', '<cmd>MarksQFListAll<CR>', { desc = '[M]arks to [Q]uickfix (all)' })
vim.keymap.set('n', '<leader>mb', '<cmd>MarksQFListBuf<CR>', { desc = '[M]arks to quickfix ([B]uffer)' })
