vim.g.mapleader = " "

require("tcreach.remap")

vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.autoread = true
vim.opt.ignorecase = true

vim.opt.scrolloff = 8

vim.opt.swapfile = false

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'echasnovski/mini.surround',
        version = '*',
        config = function()
            require('mini.surround').setup({
                mappings = {
                    add = 'gza',            -- Add surrounding in Normal and Visual modes
                    delete = 'gzd',         -- Delete surrounding
                    find = 'gzf',           -- Find surrounding (to the right)
                    find_left = 'gzF',      -- Find surrounding (to the left)
                    highlight = 'gzh',      -- Highlight surrounding
                    replace = 'gzr',        -- Replace surrounding
                    update_n_lines = 'gzn', -- Update `n_lines`

                    suffix_last = 'l',      -- Suffix to search with "prev" method
                    suffix_next = 'n',      -- Suffix to search with "next" method
                },
            })
        end
    },
    {
        'arthurxavierx/vim-caser' -- gs motion
    },
    {
        'chaoren/vim-wordmotion'
    },
    {
        'tpope/vim-unimpaired'
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            {
                "S",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter"
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash"
            },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search"
            },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search"
            },
        },
    },
})
