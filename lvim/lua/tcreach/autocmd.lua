vim.api.nvim_create_autocmd("BufWrite",
    {
        pattern = "*",
        callback = function()
            local pos = vim.fn.getpos('.');
            vim.cmd("%s/\\s\\+$//ge")
            vim.fn.setpos('.', pos);
        end
    });
