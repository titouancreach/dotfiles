lvim.autocommands = {
    -- {
    --     "ColorScheme", -- see `:h autocmd-events`
    --     {
    --         callback = function()
    --             vim.api.nvim_set_hl(0, "SLCopilot", { fg = "#000000", bg = 'NONE' })
    --         end
    --     }
    -- },
    --

    {
        "BufWrite",
        {
            pattern = "*",
            callback = function()
                if vim.bo.filetype == "markdown" then
                    return
                end

                local pos = vim.fn.getpos('.');
                vim.cmd("%s/\\s\\+$//ge")
                vim.fn.setpos('.', pos);
            end
        }
    },
    {
        "FileType",
        {
            pattern = { "NvimTree" },
            callback = function()
                vim.keymap.set('n', '<leader>o', function()
                    local api = require('nvim-tree.api')
                    local node = api.tree.get_node_under_cursor()
                    local path = node.absolute_path

                    if (path and vim.fn.isdirectory(path) == 0) then
                        path = vim.fn.fnamemodify(path, ':h')
                    end

                    require("oil").open(path)
                end, { buffer = true })
            end
        }
    }
}
