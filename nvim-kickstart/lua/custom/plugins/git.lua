return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
      'folke/snacks.nvim',
    },
    keys = {
      { '<leader>hg', '<cmd>Neogit<CR>', desc = 'Open Neo[g]it' },
      { '<leader>hd', '<cmd>DiffviewFileHistory %<CR>', desc = 'See [d]iff history for current file' },
    },
  },

  {
    'esmuellert/codediff.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    cmd = 'CodeDiff',
  },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    event = 'VeryLazy',
    keys = {
      { '<leader>hq', '<cmd>Gitsigns setqflist<CR>', desc = 'git show hunks in [Q]uicklist' },
    },
  },
}
