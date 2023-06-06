vim.api.nvim_create_autocmd("BufWrite",
    {
        pattern = "*",
        callback = function()
            vim.cmd("%s/\\s\\+$//ge")
        end
    });
