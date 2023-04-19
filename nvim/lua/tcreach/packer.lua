
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.1',
  -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use({
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
      require("rose-pine").setup()
      vim.cmd('colorscheme rose-pine')
    end,
    cond = function()
      return vim.g.vscode ~= nil
    end,
  })

  use('tpope/vim-fugitive')
  use('jnurmine/Zenburn')

  use {
    'aznhe21/hop.nvim',
    --branch = 'v2', -- optional but strongly recommended
    branch = 'fix-some-bugs', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  }

  use('tpope/vim-surround')
  use('tpope/vim-commentary')
  use('wellle/targets.vim')
  use('airblade/vim-gitgutter')

  use {
      "chrisgrieser/nvim-various-textobjs",
      config = function ()
          require("various-textobjs").setup({ useDefaultKeymaps = true })
      end,
  }

  use('rlane/pounce.nvim')

end)
