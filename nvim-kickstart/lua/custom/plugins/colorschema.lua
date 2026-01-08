return {
  -- {
  --   'projekt0n/github-nvim-theme',
  --   name = 'github-theme',
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require('github-theme').setup {
  --       -- ...
  --       --
  --     }
  --     -- vim.cmd 'colorscheme github_dark'
  --     vim.cmd 'colorscheme github_light'
  --   end,
  -- },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        show_end_of_buffer = true,
      }
      vim.cmd 'colorscheme catppuccin-frappe'
    end,
  },
  -- {
  --   'Mofiqul/vscode.nvim',
  --   config = function()
  --     vim.o.background = 'light'
  --     require('vscode').setup {}
  --     vim.cmd 'colorscheme vscode'
  --   end,
  -- },
}
