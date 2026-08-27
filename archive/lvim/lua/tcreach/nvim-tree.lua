lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

local function custom_on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.del('n', 's', { buffer = bufnr })

    vim.keymap.set('n', 's', function()
        require('flash').jump()
    end, opts('Flash'))
end

lvim.builtin.nvimtree.setup.on_attach = custom_on_attach
