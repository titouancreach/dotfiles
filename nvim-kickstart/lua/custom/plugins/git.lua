return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'sindrets/diffview.nvim', -- optional - Diff integration
      'nvim-telescope/telescope.nvim', -- optional - Telescope integration
    },
    keys = {
      { '<leader>hg', '<cmd>Neogit<CR>', desc = 'Open Neo[g]it' },
      { '<leader>hd', '<cmd>DiffviewFileHistory %<CR>', desc = 'See [d]iff history for current file' },
    },
    config = function()
      require('neogit').setup({})

      -- Command to add Claude as co-author
      vim.api.nvim_create_user_command('AddClaudeAsCoAuthor', function()
        local line = 'Co-Authored-By: Claude <noreply@anthropic.com>'
        vim.api.nvim_put({ '', line }, 'l', true, true)
      end, { desc = 'Add Claude as commit co-author' })

      -- Keymap for Neogit commit buffer
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'NeogitCommitMessage',
        callback = function()
          vim.keymap.set('n', '<leader>hc', '<cmd>AddClaudeAsCoAuthor<CR>', { buffer = true, desc = 'Add [C]laude as co-author' })
        end,
      })
    end,
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
