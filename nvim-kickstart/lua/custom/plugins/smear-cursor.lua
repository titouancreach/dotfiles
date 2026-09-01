-- Animated cursor trail
vim.pack.add { 'https://github.com/sphamba/smear-cursor.nvim' }

require('smear_cursor').setup {
  smear_between_buffers = true,
  smear_between_neighbor_lines = true,
  smear_insert_mode = true,
}
