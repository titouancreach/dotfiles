-- haskell-tools is ftplugin-driven: no setup() call needed, it activates on
-- haskell/lhaskell/cabal buffers by itself.
vim.pack.add { { src = 'https://github.com/mrcjkb/haskell-tools.nvim', version = vim.version.range '6.*' } }

vim.keymap.set('n', '<leader>hs', function()
  require('haskell-tools').hoogle.hoogle_signature()
end, { desc = '[H]oogle [S]ignature' })
