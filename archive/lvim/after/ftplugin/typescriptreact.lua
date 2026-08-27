local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        command = "prettier",
        args = { "--print-width", "100" },
        filetypes = { "typescript", "typescriptreact" },
    },
}
