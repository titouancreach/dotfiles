-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
local gh = require('config.pack').gh

-- [[ Snippet Engine ]]

-- NOTE: You can also specify plugin using a version range for its git tag.
--  See `:help vim.version.range()` for more info
vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  gh 'rafamadriz/friendly-snippets',
}
require('luasnip').setup {}

-- `friendly-snippets` contains a variety of premade snippets.
--    See the README about individual language/framework/plugin snippets:
--    https://github.com/rafamadriz/friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_vscode').load_standalone { path = '~/Code/Inato/inato-marketplace/.vscode/effect.code-snippets' }
require('luasnip.loaders.from_vscode').load_standalone { path = '~/Code/Inato/inato-marketplace/.vscode/icon.code-snippets' }
require('luasnip.loaders.from_vscode').load_standalone { path = '~/Code/Inato/inato-marketplace/.vscode/inato.code-snippets' }
require('luasnip.loaders.from_vscode').load_standalone { path = '~/Code/Inato/inato-marketplace/.vscode/story.code-snippets' }
require('luasnip.loaders.from_vscode').load_standalone { path = '~/Code/Inato/inato-marketplace/.vscode/storydoc.code-snippets' }

-- [[ Autocomplete Engine ]]
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    -- 'default' (recommended) for mappings similar to built-in completions
    --   <c-y> to accept ([y]es) the completion.
    --    This will auto-import if your LSP supports it.
    --    This will expand snippets if the LSP sent a snippet.
    --
    -- All presets have the following mappings:
    -- <tab>/<s-tab>: move to right/left of your snippet expansion
    -- <c-space>: Open menu or open docs if already open
    -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
    -- <c-e>: Hide menu
    -- <c-k>: Toggle signature help
    --
    -- See `:help blink-cmp-config-keymap` for defining your own keymap
    preset = 'default',
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  completion = {
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'lazydev' },
    per_filetype = {
      sql = { 'dadbod', 'snippets', 'buffer' },
      mysql = { 'dadbod', 'snippets', 'buffer' },
      plsql = { 'dadbod', 'snippets', 'buffer' },
    },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
    },
  },

  snippets = { preset = 'luasnip' },

  -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
  -- which automatically downloads a prebuilt binary when enabled.
  --
  -- By default, we use the Lua implementation instead, but you may enable
  -- the rust implementation via `'prefer_rust_with_warning'`
  --
  -- See `:help blink-cmp-config-fuzzy` for more information
  fuzzy = { implementation = 'lua' },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}

-- Advertise blink.cmp's extra capabilities to every LSP server (servers are
-- configured in the LSP section; the config is resolved when a server starts,
-- so registering this here is early enough).
vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
