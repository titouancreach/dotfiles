require("tcreach.options")

lvim.transparent_window = false
--
vim.g.markdown_syntax_conceal = 0

-- general
lvim.log.level = "info"

lvim.format_on_save = {
    enabled = true,
    pattern = { "*.lua", "*.tsx" },
    timeout = 1000,
}

vim.opt.listchars = { eol = '↵', space = '·', tab = '>-', nbsp = '␣' }
vim.opt.list = true

lvim.builtin.indentlines.active = true
lvim.builtin.indentlines.options = {
    buftype_exclude = { "terminal", "nofile" },
    filetype_exclude = { "help", "terminal", "dashboard", "packer", "nofile" },
    show_current_context = false,
    show_end_of_line = true,
    space_char_blankline = " ",
}

-- Add server to the skipped list
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "csharp_ls" })

require("tcreach.keymap")
require("tcreach.colors")

lvim.colorscheme = "catppuccin-macchiato"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true

lvim.builtin.illuminate.enable = false

require("tcreach.nvim-tree")

lvim.builtin.treesitter.auto_install = true
lvim.builtin.treesitter.highlight.additional_vim_regex_highlighting = true;

lvim.builtin.project.patterns = { "*.csproj", "package.json", ".git", "main.csx" }
lvim.builtin.project.silent_chdir = false

require("tcreach.plugins")
require("tcreach.autocmd")
require("tcreach.commands")

local neogit = require('neogit')

neogit.setup {
    integrations = {
        diffview = true,
        telescope = true
    },
    kind = "split_above",
    mappings = {
        status = {
            ["[c"] = "GoToPreviousHunkHeader",
            ["]c"] = "GoToNextHunkHeader",
        }
    }
}

table.insert(lvim.builtin.cmp.sources, { name = "git" })
