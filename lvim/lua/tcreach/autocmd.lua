lvim.autocommands = {
    {
        "ColorScheme", -- see `:h autocmd-events`
        {
            callback = function()
                vim.api.nvim_set_hl(0, "SLCopilot", { fg = "#000000", bg = 'NONE' })
            end
        }
    },

    {
        "BufWrite",
        {
            pattern = "*",
            callback = function()
                local pos = vim.fn.getpos('.');
                vim.cmd("%s/\\s\\+$//ge")
                vim.fn.setpos('.', pos);
            end
        }
    }
}
