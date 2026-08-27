local util = require("lspconfig.util")

local opt = {
  organize_imports_on_format = true,

  root_dir = function(fname)
    local root_patterns = { '*.sln', '*.csproj', 'omnisharp.json', 'function.json' }
    for _, pattern in ipairs(root_patterns) do
      local match = util.root_pattern(pattern)(fname)
      if match then
        return match
      end
    end
  end
}

require("lvim.lsp.manager").setup("omnisharp", opt);
