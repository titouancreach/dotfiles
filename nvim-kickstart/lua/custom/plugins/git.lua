-- Git tooling: Neogit (status/commit UI), codediff (diff/history viewer),
-- octo (GitHub issues/PRs). gitsigns lives in init.lua.
-- plenary, nui, telescope and nvim-web-devicons are installed by init.lua.
vim.pack.add {
  'https://github.com/NeogitOrg/neogit',
  'https://github.com/esmuellert/codediff.nvim',
  'https://github.com/pwntester/octo.nvim',
}

require('neogit').setup {
  integrations = {
    codediff = true,
  },
}
vim.keymap.set('n', '<leader>hg', '<cmd>Neogit<CR>', { desc = 'Open Neo[g]it' })

require('codediff').setup {
  keymaps = {
    view = {
      -- AZERTY convention (matches bracketed.lua / gitsigns): < = next, > = previous.
      -- These are codediff's own hunk maps, buffer-local, so they win over the
      -- global gitsigns <c/>c inside a codediff diff.
      next_hunk = '<c',
      prev_hunk = '>c',
    },
  },
}
-- Compat shim for the Neogit -> codediff bridge (neogit issue #2008).
-- codediff 2.67.9 (commit 48576d2, 2026-08-27) replaced `mode`/`explorer_data`
-- with `panel = { name, data }`, and had already replaced `original_path`/
-- `modified_path` with typed `original`/`modified` Paths. Neogit's
-- integrations/codediff.lua still sends the old shape, so `dd` on a file in the
-- status buffer opened nothing (or errored with "attempt to index local 'ref'").
-- Translate old -> new here until upstream neogit ships the fix, then delete.
do
  local view = require 'codediff.ui.view'
  local path = require 'codediff.core.path'
  local create = view.create
  view.create = function(cfg, ...)
    if type(cfg) == 'table' and cfg.panel == nil and cfg.original == nil then
      if cfg.mode == 'explorer' then
        cfg.panel = { name = 'explorer', data = cfg.explorer_data or {} }
      elseif cfg.mode == 'history' then
        cfg.panel = { name = 'history', data = cfg.history_data or {} }
      end
      cfg.original = path.make_ref(cfg.original_path, cfg.git_root)
      cfg.modified = path.make_ref(cfg.modified_path, cfg.git_root)
      cfg.mode, cfg.explorer_data, cfg.history_data = nil, nil, nil
      cfg.original_path, cfg.modified_path = nil, nil
    end
    return create(cfg, ...)
  end
end

-- Commit-to-commit review: commit-log panel beside the diff.
-- Move commits with j/k, press <CR> to load the selected commit's diff.
vim.keymap.set('n', '<leader>gh', '<cmd>CodeDiff history<CR>', { desc = 'git [h]istory (codediff commit browser)' })

require('octo').setup {
  -- or "fzf-lua" or "snacks" or "default"
  picker = 'telescope',
  -- bare Octo command opens picker of commands
  enable_builtin = true,
}
vim.keymap.set('n', '<leader>oi', '<CMD>Octo issue list<CR>', { desc = 'List GitHub Issues' })
vim.keymap.set('n', '<leader>op', '<CMD>Octo pr list<CR>', { desc = 'List GitHub PullRequests' })
vim.keymap.set('n', '<leader>od', '<CMD>Octo discussion list<CR>', { desc = 'List GitHub Discussions' })
vim.keymap.set('n', '<leader>on', '<CMD>Octo notification list<CR>', { desc = 'List GitHub Notifications' })
vim.keymap.set('n', '<leader>os', function()
  require('octo.utils').create_base_search_command { include_current_repo = true }
end, { desc = 'Search GitHub' })
