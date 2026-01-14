return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    styles = {
      preview = {
        treesitter = {
          enabled = true,
        },
      },
    },
    dashboard = {
      preset = {
        pick = nil,
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1, limit = 9 },
        { section = 'startup' },
      },

      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = true },
      browse = { enabled = true },
      notifier = { enabled = true },
      gitbrowse = { enbled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
      gh = { enabled = true },
      picker = {
        formatters = {
          file = {
            filename_first = true,
          },
        },
        preview = {
          treesitter = {
            enabled = true,
          },
        },
        win = {
          preview = {
            treesitter = {
              enabled = true,
            },
          },
        },
        sources = {
          gh_issue = {},
          gh_pr = {},
        },
      },
    },
  },

  config = function(_, opts)
    require('snacks').setup(opts)

    vim.api.nvim_create_user_command('GitLink', function(cmd_opts)
      require('snacks').gitbrowse {
        branch = 'main', -- Matches your coworker's config
        line_start = cmd_opts.line1, -- Supports visual selection
        line_end = cmd_opts.line2,
        open = function(url)
          vim.fn.setreg('+', url) -- Copy to clipboard
          vim.notify("Copied 'main' link to clipboard", vim.log.levels.INFO, { title = 'Snacks' })
        end,
      }
    end, {
      desc = 'Create GitHub link to current line or visual selection',
      range = true,
    })
  end,

  keys = {
    {
      '<leader>gi',
      function()
        Snacks.picker.gh_issue()
      end,
      desc = 'GitHub Issues (open)',
    },
    {
      '<leader>gI',
      function()
        Snacks.picker.gh_issue { state = 'all' }
      end,
      desc = 'GitHub Issues (all)',
    },
    {
      '<leader>gp',
      function()
        Snacks.picker.gh_pr()
      end,
      desc = 'GitHub Pull Requests (open)',
    },
    {
      '<leader>gP',
      function()
        Snacks.picker.gh_pr { state = 'all' }
      end,
      desc = 'GitHub Pull Requests (all)',
    },
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
  },
}
