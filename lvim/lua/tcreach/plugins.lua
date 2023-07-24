lvim.plugins = {
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
                            accept = "<C-y>"
                        },
                        filetypes = {
                            ["*"] = true
                        }
                    }
                })
            end, 100)
        end,
    },
    {
        "tpope/vim-fugitive",
        cmd = {
            "G",
            "Git",
            "Gdiffsplit",
            "Gread",
            "Gwrite",
            "Ggrep",
            "GMove",
            "GDelete",
            "GBrowse",
            "GRemove",
            "GRename",
            "Glgrep",
            "Gedit"
        },
        ft = { "fugitive" }
    },
    {
        "tpope/vim-surround",
    },
    {
        "chrisgrieser/nvim-various-textobjs",
        opts = { useDefaultKeymaps = true },
    },
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
    { "wellle/targets.vim" },
    -- {
    --     "projekt0n/github-nvim-theme",
    --     lazy = false,
    --     config = function()
    --         local theme = 'github_dark';

    --         local palette = require('github-theme.palette').load(theme)
    --         local Color = require('github-theme.lib.color')

    --         local bg = Color.from_hex(palette.canvas.default);

    --         local darken = bg:lighten(-2):to_css();
    --         local darkenplus = bg:lighten(-20):to_css();

    --         print(darkenplus)

    --         require('github-theme').setup({
    --             options = {
    --                 hide_end_of_buffer = false,
    --                 dim = false
    --             },
    --             groups = {
    --                 all = {
    --                     Whitespace = { fg = darkenplus },
    --                     NonText = { fg = darkenplus },
    --                     SpecialKey = { fg = darkenplus },
    --                     CursorLine = { bg = darken },
    --                 }
    --             }
    --         })
    --         -- vim.cmd('colorscheme ' .. theme)
    --     end,
    -- },
    {
        'mileszs/ack.vim',
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
                        end
                    },
                },
                -- Jump to request line on run
                jump_to_request = false,
                env_file = '.env',
                custom_dynamic_variables = {},
                yank_dry_run = true,
            })
        end
    },
    {
        "nvim-zh/colorful-winsep.nvim",
        config = true,
        event = { "WinNew" },
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup();
        end
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            colors = {
                -- default is DiagnosticHint but this hl group is used in other places so I don't want to make a side effect
                hint = { "DiagnosticInfo", "#10B981" },
            },
        }
    },
    {
        'tpope/vim-abolish'
    },
    {
        'arthurxavierx/vim-caser'
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
            require "telescope".load_extension("frecency")
        end,
        dependencies = { "kkharji/sqlite.lua" }
    },
    {
        "folke/zen-mode.nvim",
        opts = {
            window = {
                width = 0.8,
            }
        }
    },
    {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        config = function()
            require "telescope".load_extension("smart_open")
        end,
        dependencies = {
            "kkharji/sqlite.lua",
            -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
            { "nvim-telescope/telescope-fzy-native.nvim" },
        }
    },
    {
        'abecodes/tabout.nvim',
        config = function()
            require('tabout').setup {
                tabkey = '<Tab>',             -- key to trigger thttps://github.com/about, set to an empty string to disable
                backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
                act_as_tab = true,            -- shift content if tab out is not possible
                act_as_shift_tab = false,     -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                default_tab = '<C-t>',        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
                default_shift_tab = '<C-d>',  -- reverse shift default action,
                enable_backwards = true,      -- well ...
                completion = false,           -- if the tabkey is used in a completion pum
                tabouts = {
                    { open = "'", close = "'" },
                    { open = '"', close = '"' },
                    { open = '`', close = '`' },
                    { open = '(', close = ')' },
                    { open = '[', close = ']' },
                    { open = '{', close = '}' }
                },
                ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                exclude = {} -- tabout will ignore these filetypes
            }
        end,
        dependencies = { 'nvim-treesitter' }, -- or require if not used so far
    },
    {
        "nvim-pack/nvim-spectre",
        event = "BufRead",
        config = function()
            require("spectre").setup()
        end,
    },
    {
        'nmac427/guess-indent.nvim',
        config = function() require('guess-indent').setup {} end,
    },
    {
        'chaoren/vim-wordmotion'
    },
    {
        'nvim-treesitter/playground'
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
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
                mode = { "n", "o" },
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
                desc = "Flash Treesitter Search",
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
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end
    },
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        init = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
    },
    {
        'voldikss/vim-browser-search',
        cmd = { 'BrowserSearch' },
    },
    {
        'j-morano/buffer_manager.nvim',
        keys = {
            {
                '<C-b>',
                function()
                    require("buffer_manager.ui").toggle_quick_menu()
                end,
                desc = 'Open buffer manager'
            }
        }
    },
    {
        "sindrets/diffview.nvim"
    },
    {
        'NeogitOrg/neogit',
        dependencies = { 'nvim-lua/plenary.nvim', 'sindrets/diffview.nvim' },
    },
    {
        'arcticicestudio/nord-vim'
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require('catppuccin').setup({
                show_end_of_buffer = true,
                custom_highlights = function(color)
                    return {
                        Whitespace = { link = "NonText" }
                    }
                end
            })
        end
    }
}
