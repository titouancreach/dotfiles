-- To play just
--
-- :GithubThemeInteractive and then save

require('github-theme').setup({
    options = {
        hide_end_of_buffer = false,
        dim_inactive = true,
    },
    groups = {
        all = {
            Whitespace = { fg = '#cccccc' },
            NonText = { fg = '#cccccc' },
            CursorLine = { bg = '#f6f8fa' },
            SLCopilot = { bg = '#000000', fg = '#000000' }
        }
    }
})

require('github-theme').compile()
vim.cmd('colorscheme github_light')
