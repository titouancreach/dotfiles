lvim.plugins = {
    {
        dir = "/Users/tcreach/Documents/Code/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesj").setup({ --[[ your config ]]
            })
        end,
    },
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            vim.defer_fn(function()
                require("copilot").setup({
                    suggestion = {
                        auto_trigger = true,
                        keymap = {
                            accept = "<C-y>",
                        },
                        filetypes = {
                            ["*"] = true,
                        },
                    },
                })
            end, 100)
        end,
    },
    {
        "echasnovski/mini.surround",
        version = "*",
        config = function()
            require("mini.surround").setup({
                mappings = {
                    add = "gza",            -- Add surrounding in Normal and Visual modes
                    delete = "gzd",         -- Delete surrounding
                    find = "gzf",           -- Find surrounding (to the right)
                    find_left = "gzF",      -- Find surrounding (to the left)
                    highlight = "gzh",      -- Highlight surrounding
                    replace = "gzr",        -- Replace surrounding
                    update_n_lines = "gzn", -- Update `n_lines`

                    suffix_last = "l",      -- Suffix to search with "prev" method
                    suffix_next = "n",      -- Suffix to search with "next" method
                },
            })
        end,
    },
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
    {
        'TobinPalmer/BetterGX.nvim',
        keys = {
            { 'gx', function()
                return require("better-gx").BetterGx()
            end
            }
        }
    },
    {
        "mileszs/ack.vim",
    },
    {
        "rest-nvim/rest.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("rest-nvim").setup({
                -- Open request results in a horizontal split
                result_split_horizontal = false,
                -- Keep the http file buffer above|left when split horizontal|vertical
                result_split_in_place = false,
                -- Skip SSL verification, useful for unknown certificates
                skip_ssl_verification = false,
                -- Encode URL before making request
                encode_url = true,
                -- Highlight request on run
                highlight = {
                    enabled = true,
                    timeout = 150,
                },
                result = {
                    -- toggle showing URL, HTTP info, headers at top the of result window
                    show_url = true,
                    show_http_info = true,
                    show_headers = true,
                    -- executables or functions for formatting response body [optional]
                    -- set them to false if you want to disable them
                    formatters = {
                        json = "jq",
                        html = function(body)
                            return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
                        end,
                    },
                },
                -- Jump to request line on run
                jump_to_request = false,
                env_file = ".env",
                custom_dynamic_variables = {},
                yank_dry_run = true,
            })
        end,
    },
    {
        "nvim-zh/colorful-winsep.nvim",
        config = true,
        event = { "WinNew" },
    },
    {
        "stevearc/oil.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup()
        end,
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            colors = {},
        },
    },
    {
        "tpope/vim-abolish",
    },
    {
        "arthurxavierx/vim-caser", -- gs motion
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
            require("telescope").load_extension("frecency")
        end,
        dependencies = { "kkharji/sqlite.lua" },
    },
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
                width = 0.8,
            },
        },
    },
    {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        config = function()
            require("telescope").load_extension("smart_open")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
            -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
            { "nvim-telescope/telescope-fzy-native.nvim" },
        },
    },
    {
        "nmac427/guess-indent.nvim",
        config = function()
            require("guess-indent").setup({})
        end,
    },
    {
        "chaoren/vim-wordmotion",
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function()
                    require("flash").jump()
                end,
                desc = "Flash",
            },
            {
                "S",
                mode = { "n", "o", "x" },
                function()
                    require("flash").treesitter()
                end,
                desc = "Flash Treesitter",
            },
            {
                "r",
                mode = "o",
                function()
                    require("flash").remote()
                end,
                desc = "Remote Flash",
            },
            {
                "R",
                mode = { "o", "x" },
                function()
                    require("flash").treesitter_search()
                end,
                desc = "Treesitter Search",
            },
            {
                "<c-s>",
                mode = { "c" },
                function()
                    require("flash").toggle()
                end,
                desc = "Toggle Flash Search",
            },
        },
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                ["*"] = {
                    names = false,
                },
            })
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    {
        "voldikss/vim-browser-search",
        cmd = { "BrowserSearch" },
    },
    {
        "sindrets/diffview.nvim",
    },
    {
        "NeogitOrg/neogit",
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                show_end_of_buffer = true,
                custom_highlights = function(_)
                    return {
                        Whitespace = { link = "NonText" },
                    }
                end,
                integrations = {
                    noice = true,
                    notify = true,
                    neogit = true,
                    which_key = true,
                    telescope = {
                        enabled = true,
                        style = "nvchad"
                    }
                }
            })
        end,
    },
    {
        "tpope/vim-unimpaired",
    },
    {
        "petertriho/cmp-git",
        ft = { "NeogitCommitMessage" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("cmp_git").setup({
                filetypes = { "NeogitCommitMessage" },
            })
        end,
    },
    {
        "tpope/vim-dadbod",
    },
    {
        "abecodes/tabout.nvim",
        event = "InsertEnter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("tabout").setup({
                tabkey = "<Tab>",             -- key to trigger tabout, set to an empty string to disable
                backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
                act_as_tab = true,            -- shift content if tab out is not possible
                act_as_shift_tab = false,     -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                default_tab = "<C-t>",        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
                default_shift_tab = "<C-d>",  -- reverse shift default action,
                enable_backwards = true,      -- well ...
                completion = true,            -- if the tabkey is used in a completion pum
                tabouts = {
                    { open = "'", close = "'" },
                    { open = '"', close = '"' },
                    { open = "`", close = "`" },
                    { open = "(", close = ")" },
                    { open = "[", close = "]" },
                    { open = "{", close = "}" },
                },
                ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                exclude = {}, -- tabout will ignore these filetypes
            })
        end,
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true,         -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false,       -- add a border to hover docs and signature help
                },
            })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },
    'https://github.com/Konfekt/vim-CtrlXA'
}
