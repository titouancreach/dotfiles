--
-- Change colorscheme for Haskell files only
--

vim.api.nvim_create_augroup('FiletypeColors', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'FileType' }, {
  group = 'FiletypeColors',
  pattern = 'haskell',
  callback = function()
    vim.o.termguicolors = true
    vim.o.background = 'light'
    require('solarized').setup {
      variant = 'winter',
      on_highlights = function(colors, color)
        return {
          Whitespace = { fg = '#cccccc' },
          NonText = { fg = '#cccccc' },
          SpecialKey = { fg = '#cccccc' },
          EndOfBuffer = { fg = '#cccccc' },
        }
      end,
    } -- or your desired variant
    vim.cmd.colorscheme 'solarized'
  end,
})

-- When leaving a Haskell file → restore default scheme
return {
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
  },

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('github-theme').setup {
        -- ...
      }

      vim.cmd 'colorscheme github_dark'
      -- vim.cmd 'colorscheme github_light'
    end,
  },
}
