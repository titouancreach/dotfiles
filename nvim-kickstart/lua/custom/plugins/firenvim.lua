-- Nvim inside browser text areas. The browser-side runtime is installed by
-- the PackChanged hook in init.lua (`firenvim#install(0)`).

-- Must be set before the plugin loads
vim.g.firenvim_config = {
  globalSettings = { alt = 'all' },
  localSettings = {
    ['.*'] = { takeover = 'never' },
  },
}

vim.pack.add { 'https://github.com/glacambre/firenvim' }

if vim.g.started_by_firenvim then
  vim.o.laststatus = 0
  vim.o.guifont = 'monospace:h14'
end
