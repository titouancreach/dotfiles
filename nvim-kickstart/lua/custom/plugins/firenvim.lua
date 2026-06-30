return {
  {
    'glacambre/firenvim',
    lazy = false,
    build = ':call firenvim#install(0)',
    init = function()
      vim.g.firenvim_config = {
        globalSettings = { alt = 'all' },
        localSettings = {
          ['.*'] = { takeover = 'never' },
        },
      }
    end,
    config = function()
      if vim.g.started_by_firenvim then
        vim.o.laststatus = 0
        vim.o.guifont = 'monospace:h14'
      end
    end,
  },
}
