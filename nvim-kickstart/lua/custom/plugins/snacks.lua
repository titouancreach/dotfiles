-- Collection of QoL plugins (dashboard, notifier, pickers for GitHub, ...)
vim.pack.add { 'https://github.com/folke/snacks.nvim' }

---@diagnostic disable-next-line: missing-fields
require('snacks').setup {
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
      -- Neovim version under the header, e.g. "NVIM v0.13.0-nightly+4b3ab0d"
      -- (first line of `:version`, which carries the nightly build hash).
      {
        text = {
          { vim.api.nvim_exec2('version', { output = true }).output:match('^[^\n]+'), hl = 'footer' },
        },
        align = 'center',
        padding = 1,
      },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1, limit = 9 },
      -- NOTE: no `{ section = 'startup' }`: it requires 'lazy.stats' (lazy.nvim only)
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
}

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

vim.keymap.set('n', '<leader>gi', function()
  Snacks.picker.gh_issue()
end, { desc = 'GitHub Issues (open)' })
vim.keymap.set('n', '<leader>gI', function()
  Snacks.picker.gh_issue { state = 'all' }
end, { desc = 'GitHub Issues (all)' })
vim.keymap.set('n', '<leader>gp', function()
  Snacks.picker.gh_pr()
end, { desc = 'GitHub Pull Requests (open)' })
vim.keymap.set('n', '<leader>gP', function()
  Snacks.picker.gh_pr { state = 'all' }
end, { desc = 'GitHub Pull Requests (all)' })
vim.keymap.set('n', '<leader>.', function()
  Snacks.scratch()
end, { desc = 'Toggle Scratch Buffer' })
vim.keymap.set('n', '<leader>S', function()
  Snacks.scratch.select()
end, { desc = 'Select Scratch Buffer' })
