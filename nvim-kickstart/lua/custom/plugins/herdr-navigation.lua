-- <C-h/j/k/l> navigation across nvim splits AND the surrounding herdr panes.
--
-- herdr side: the vim-herdr-navigation plugin (`herdr plugin list`) binds the
-- same chords and forwards them here when nvim is the foreground process.

-- The managed checkout carries a content hash, so resolve it by glob
-- instead of hardcoding the path (it changes on `herdr plugin install`).
local matches = vim.fn.glob(vim.fn.expand '~/.config/herdr/plugins/github/vim-herdr-navigation-*/editor/nvim.lua', false, true)
if #matches > 0 then
  dofile(matches[1])
  return
end

-- Plugin missing (fresh machine, not installed yet): plain split navigation.
for lhs, dir in pairs { ['<C-h>'] = 'h', ['<C-j>'] = 'j', ['<C-k>'] = 'k', ['<C-l>'] = 'l' } do
  vim.keymap.set('n', lhs, '<C-w>' .. dir, { desc = 'Navigate split' })
end
