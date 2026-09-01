-- cspell diagnostics + code actions through none-ls (plenary comes from init.lua)
vim.pack.add {
  'https://github.com/nvimtools/none-ls.nvim',
  'https://github.com/davidmh/cspell.nvim',
}

local cspell = require 'cspell'

require('null-ls').setup {
  sources = {
    cspell.diagnostics.with {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    },
    cspell.code_actions,
  },
}
