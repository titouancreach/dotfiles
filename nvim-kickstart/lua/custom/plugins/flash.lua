-- Jump anywhere with labeled search (s / S in normal, x, o modes)
vim.pack.add { 'https://github.com/folke/flash.nvim' }

require('flash').setup {
  label = {
    rainbow = {
      enabled = true,
      -- number between 1 and 9
      shade = 2,
    },
  },

  modes = {
    search = {
      enabled = true,
    },
    char = {
      jump_labels = true,
    },
  },
}

vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function()
  require('flash').remote()
end, { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })
vim.keymap.set('c', '<c-s>', function()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })
