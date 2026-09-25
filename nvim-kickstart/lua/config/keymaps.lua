-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- <Esc> in normal mode: clear search highlights and remove all multicursors
-- (|multicursor|, nvim 0.13). The default <C-L> does both, but <C-l> is
-- taken by the herdr split navigation (lua/custom/plugins/herdr-navigation.lua).
vim.keymap.set('n', '<Esc>', function()
  vim.cmd.nohlsearch()
  vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace 'nvim.multicursor', 0, -1)
end, { desc = 'Clear search highlight and multicursors' })

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
  },

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = '[E]xtend [d]iagnostic text' })

-- Paste without overwriting register
vim.keymap.set('v', 'p', '"_dP')

-- Yank to the system clipboard (no global clipboard sync on purpose)
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set('n', '<leader>Y', function()
  vim.fn.setreg('+', vim.fn.getreg '"')
end, { desc = 'Copy last yanked text to system clipboard' })

-- NOTE: This won't work in all terminal emulators/tmux/etc.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Navigation between splits is handled by herdr
-- See lua/custom/plugins/herdr-navigation.lua

-- Save with <leader>w
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite current buffer' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})

vim.api.nvim_create_user_command('QfUpdate', function()
  require('inato').update_quickfix()
end, {})
