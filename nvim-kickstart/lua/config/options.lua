-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.shiftwidth = 2 -- number of spaces per indentation level
vim.opt.tabstop = 2 -- number of spaces for a “tab” in the file
vim.opt.softtabstop = 2

vim.opt.background = 'dark' -- match the dark rose-pine-moon colorscheme

-- [[ Setting options ]]
--  See `:help vim.o`

-- Make line numbers default
vim.o.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Persistent undo. Nvim encodes the full file path into the undo file *name*,
-- which overflows the 255-byte filename component limit on deep paths (E828 on
-- write) — so disable it per-buffer only when the encoded name would be too long.
vim.o.undofile = true
vim.api.nvim_create_autocmd('BufReadPre', {
  group = vim.api.nvim_create_augroup('undofile-deep-path-guard', { clear = true }),
  callback = function(ev)
    local encoded = ev.file:gsub('/', '%%')
    if #encoded > 250 then
      vim.bo[ev.buf].undofile = false
    end
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Display certain whitespace characters in the editor
--  See `:help 'list'` and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', lead = '·' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Folds come from treesitter (set window-locally on attach, see the
-- treesitter section); keep them open by default.
vim.opt.foldenable = false
