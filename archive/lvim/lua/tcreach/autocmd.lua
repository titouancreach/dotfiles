lvim.autocommands = {
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
    },
    {
        "FileType",
        {
            pattern = { "NeogitCommitMessage" },
            callback = function()
                vim.cmd("set buflisted")
            end
        }
    },
    {
        "InsertCharPre",
        {
            pattern = { "*.cs" },
            --- @param opts AutoCmdCallbackOpts
            --- @return nil
            callback = function(opts)
                -- Only run if f-string escape character is typed
                if vim.v.char ~= "{" then return end

                -- Get node and return early if not in a string
                local node = vim.treesitter.get_node()

                if not node then return end
                if node:type() ~= "string_literal" then node = node:parent() end
                if not node or node:type() ~= "string_literal" then return end

                local row, col, _, _ = vim.treesitter.get_node_range(node)

                vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|i$<Esc>`'la")
            end
        }
    }
}

