vim.api.nvim_set_keymap('n', '<leader>twr', "<cmd>lua require('neotest').run.run({ vitestCommand = 'vitest --watch' })<cr>", { desc = 'Run Watch' })

vim.api.nvim_set_keymap(
  'n',
  '<leader>twf',
  "<cmd>lua require('neotest').run.run({ vim.fn.expand('%'), vitestCommand = 'vitest --watch' })<cr>",
  { desc = 'Run Watch File' }
)

return {
  'nvim-neotest/neotest',
  dependencies = {
    'benelan/neotest-vitest',
    'nvim-neotest/nvim-nio',
  },
  opts = {
    adapters = {
      ['neotest-vitest'] = {},
    },
  },
}
