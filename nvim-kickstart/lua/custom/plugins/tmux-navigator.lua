-- <C-h/j/k/l> navigation across nvim splits AND the surrounding multiplexer.
--
-- herdr side: the vim-herdr-navigation plugin (`herdr plugin list`) binds the
-- same chords and forwards them here when nvim is the foreground process.
-- vim-tmux-navigator is kept but with its own mappings disabled: the herdr
-- editor script falls back to TmuxNavigate* when $TMUX is set, so the old tmux
-- setup keeps working during the migration.

-- Must be set before the plugin loads
vim.g.tmux_navigator_no_mappings = 1

vim.pack.add { 'https://github.com/christoomey/vim-tmux-navigator' }

-- The managed checkout carries a content hash, so resolve it by glob
-- instead of hardcoding the path (it changes on `herdr plugin install`).
local matches = vim.fn.glob(vim.fn.expand '~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua', false, true)
if #matches > 0 then
  dofile(matches[1])
  return
end

-- Plugin missing (fresh machine, not installed yet): keep tmux behaviour.
vim.notify('vim-herdr-navigation not found; falling back to vim-tmux-navigator maps', vim.log.levels.WARN)
for lhs, cmd in pairs {
  ['<C-h>'] = 'TmuxNavigateLeft',
  ['<C-j>'] = 'TmuxNavigateDown',
  ['<C-k>'] = 'TmuxNavigateUp',
  ['<C-l>'] = 'TmuxNavigateRight',
} do
  vim.keymap.set('n', lhs, '<cmd>' .. cmd .. '<cr>', { silent = true, desc = 'Navigate (tmux)' })
end
