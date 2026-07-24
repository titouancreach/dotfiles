return {
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required
      'esmuellert/codediff.nvim', -- optional - Diff integration
      'nvim-telescope/telescope.nvim', -- optional - Telescope integration
    },
    keys = {
      { '<leader>hg', '<cmd>Neogit<CR>', desc = 'Open Neo[g]it' },
    },
    opts = {
      integrations = {
        codediff = true,
      },
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
      -- Inline blame at end of the current line, like VSCode/GitLens.
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 300,
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '  <author>, <author_time:%R> · <summary>',
    },
    event = 'VeryLazy',
    keys = {
      { '<leader>hq', '<cmd>Gitsigns setqflist<CR>', desc = 'git show hunks in [Q]uicklist' },
      { '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', desc = 'git [t]oggle line [b]lame' },
    },
  },
  {
    'pwntester/octo.nvim',
    cmd = 'Octo',
    opts = {
      -- or "fzf-lua" or "snacks" or "default"
      picker = 'telescope',
      -- bare Octo command opens picker of commands
      enable_builtin = true,
    },
    keys = {
      {
        '<leader>oi',
        '<CMD>Octo issue list<CR>',
        desc = 'List GitHub Issues',
      },
      {
        '<leader>op',
        '<CMD>Octo pr list<CR>',
        desc = 'List GitHub PullRequests',
      },
      {
        '<leader>od',
        '<CMD>Octo discussion list<CR>',
        desc = 'List GitHub Discussions',
      },
      {
        '<leader>on',
        '<CMD>Octo notification list<CR>',
        desc = 'List GitHub Notifications',
      },
      {
        '<leader>os',
        function()
          require('octo.utils').create_base_search_command { include_current_repo = true }
        end,
        desc = 'Search GitHub',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
}
