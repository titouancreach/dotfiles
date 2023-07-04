--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]

require("tcreach.options")

lvim.transparent_window = false
-- lvim.builtin.lualine.style = "default"

-- general
lvim.log.level = "info"

lvim.format_on_save = {
    enabled = true,
    pattern = { "*.lua", "*.tsx" },
    timeout = 1000,
}


lvim.builtin.indentlines.active = true
lvim.builtin.indentlines.options = {
    buftype_exclude = { "terminal", "nofile" },
    filetype_exclude = { "help", "terminal", "dashboard", "packer", "nofile" },
    show_current_context = true,
    show_end_of_line = true,
    space_char_blankline = " ",
    space_char_indent = " ",
}


-- Add server to the skipped list
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "csharp_ls" })
--vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, {})
--
lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
    return server ~= "omnisharp"
end, lvim.lsp.automatic_configuration.skipped_servers)

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false
--
require("tcreach.keymap")
-- require("tcreach.dap");
--
-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
--
require("tcreach.colors")

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true

lvim.builtin.illuminate.enable = false

require("tcreach.nvim-tree")

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true
lvim.builtin.treesitter.highlight.additional_vim_regex_highlighting = true;


-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
require("tcreach.lsp")

lvim.builtin.project.patterns = { "*.csproj", "package.json", ".git" }
lvim.builtin.project.silent_chdir = false

-- -- linters, formatters and code actions <https://www.lunarvim.org/docs/languages#lintingformatting>
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "stylua" },
--   {
--     command = "prettier",
--     extra_args = { "--print-width", "100" },
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }
-- local code_actions = require "lvim.lsp.null-ls.code_actions"
-- code_actions.setup {
--   {
--     exe = "eslint",
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

require("tcreach.plugins")
require("tcreach.autocmd")
require("tcreach.commands")
