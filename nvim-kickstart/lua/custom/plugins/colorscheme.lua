return {
  {
    -- maintained fork of nord.nvim (shaunsingh's is unmaintained since 2024
    -- and paints DiffAdd/DiffDelete as solid reverse blocks, which breaks
    -- Neogit / codediff line backgrounds)
    'gbprod/nord.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nord').setup { diff = { mode = 'fg' } } -- 'bg' is reverse-video solid blocks
      vim.cmd.colorscheme 'nord'
    end,
  },
}
