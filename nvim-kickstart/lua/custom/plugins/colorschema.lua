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
    'sainnhe/everforest',
    priority = 1000,
    config = function()
      -- Match Ghostty's "Everforest Dark Hard" palette
      vim.o.background = 'dark'
      vim.g.everforest_background = 'hard'
      vim.g.everforest_enable_italic = 0
      vim.g.everforest_disable_italic_comment = 1
      vim.g.everforest_better_performance = 1
      vim.g.everforest_show_eob = 1 -- show end-of-buffer ~, like the old catppuccin config
      vim.cmd 'colorscheme everforest'
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
