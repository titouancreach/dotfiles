return {
  dir = '~/Code/dotfiles/prtour.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'MunifTanjim/nui.nvim',
    'esmuellert/codediff.nvim', -- 'D' opens a file in codediff
    { dir = '~/Code/dotfiles/review.nvim' }, -- reused: popup, highlights, comment types
  },
  cmd = { 'PrTour' },
  keys = {
    { '<leader>pt', '<cmd>PrTour<cr>', desc = 'PR Tour (pick)' },
    { '<leader>pu', '<cmd>PrTour url<cr>', desc = 'PR Tour (by URL)' },
    { '<leader>pl', '<cmd>PrTour local<cr>', desc = 'PR Tour (local changes)' },
  },
  opts = {},
}
