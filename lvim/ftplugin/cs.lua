local util = require("lspconfig.util")
-- local configs = require("lspconfig.configs")
-- local Log = require("lvim.core.log")

-- configs["vscode-csharp"] = {
--     default_config = {
--         cmd = { "dotnet",
--             "/Users/tcreach/.vscode-insiders/extensions/ms-dotnettools.csharp-2.0.212-darwin-arm64/.roslyn/Microsoft.CodeAnalysis.LanguageServer.dll",
--             "--logLevel", "Information",
--             "--starredCompletionComponentPath",
--             "/Users/tcreach/.vscode-insiders/extensions/ms-dotnettools.vscodeintellicode-csharp-0.1.9-darwin-arm64/components/starred-suggestions/node_modules/@vsintellicode/starred-suggestions-csharp",
--             "--extension",
--             "/Users/tcreach/.vscode-insiders/extensions/ms-dotnettools.csdevkit-0.1.103-darwin-arm64/components/roslyn-visualstudio-languageservices-devkit/node_modules/@microsoft/visualstudio-languageservices-devkit/Microsoft.VisualStudio.LanguageServices.DevKit.dll",
--             "--sessionId", "db4f6427-9a34-4ddc-bed3-d674979f4cb51687418379939",
--             "--telemetryLevel", "all"
--         },
--         filetypes = { "cs" },
--         root_dir = function(fname)
--             return util.root_pattern '*.sln' (fname) or util.root_pattern '*.csproj' (fname)
--         end,

--         on_new_config = function(new_config, new_root_dir)
--             print("[CREACH LSP] on_new_config")
--             Log:warn("on_new_config")
--         end,
--     }
-- }

-- local opts = {
-- }

-- require("lvim.lsp.manager").setup("vscode-csharp", opts)
--
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
