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
    keys = {
      -- Commit-to-commit review: commit-log panel beside the diff.
      -- Move commits with j/k, press <CR> to load the selected commit's diff.
      { '<leader>gh', '<cmd>CodeDiff history<CR>', desc = 'git [h]istory (codediff commit browser)' },
    },
    opts = {
      keymaps = {
        view = {
          -- AZERTY convention (matches bracketed.lua / gitsigns): < = next, > = previous.
          -- These are codediff's own hunk maps, buffer-local, so they win over the
          -- global gitsigns <c/>c inside a codediff diff.
          next_hunk = '<c',
          prev_hunk = '>c',
        },
      },
    },
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
      -- Change navigation, AZERTY convention: < = next, > = previous (matches bracketed.lua).
      -- In a diff window use builtin ]c/[c; in a normal buffer use gitsigns hunks.
      {
        '<c',
        function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            require('gitsigns').nav_hunk 'next'
          end
        end,
        desc = 'git next hunk/change',
      },
      {
        '>c',
        function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            require('gitsigns').nav_hunk 'prev'
          end
        end,
        desc = 'git previous hunk/change',
      },
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
