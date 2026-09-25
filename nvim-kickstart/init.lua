-- Personal config based on kickstart.nvim (vim.pack edition).
-- Structure follows upstream's numbered sections; deliberate deviations:
--   - rose-pine (moon) + lualine instead of tokyonight + mini.statusline
--   - no Mason: LSP/formatter/linter binaries come from the nix profile
--     (../flake.nix) or workspace node_modules (tsgo, oxlint)
--   - no OS clipboard sync: explicit <leader>y / <leader>Y instead
--   - extra plugins live in lua/custom/plugins/*.lua (auto-loaded)

-- Each numbered section lives in lua/config/<name>.lua, loaded in order.
require 'config.options'
require 'config.keymaps'
require 'config.pack'
require 'config.ui'
require 'config.search'
require 'config.lsp'
require 'config.format'
require 'config.completion'
require 'config.treesitter'

-- ============================================================
-- SECTION 10: OPTIONAL KICKSTART PLUGINS & CUSTOM PLUGINS
-- ============================================================
do
  -- Optional kickstart plugins (from the kickstart repo)
  require 'kickstart.plugins.autopairs'
  require 'kickstart.plugins.neo-tree'
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- NOTE: gitsigns (with keymaps) is configured in lua/config/ui.lua

  -- Personal plugins from `lua/custom/plugins/*.lua` (auto-loaded)
  require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
