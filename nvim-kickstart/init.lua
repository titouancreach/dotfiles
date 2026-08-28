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

vim.opt.background = 'dark' -- match the dark nord colorscheme

-- [[ Setting options ]]
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

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

-- [[ Basic Keymaps ]]

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = '[E]xtend [d]iagnostic text' })

-- Paste without overwriting register
vim.keymap.set('v', 'p', '"_dP')

-- Yank to the system clipboard
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set('n', '<leader>Y', function()
  vim.fn.setreg('+', vim.fn.getreg '"')
end, { desc = 'Copy last yanked text to system clipboard' })

-- NOTE: This won't work in all terminal emulators/tmux/etc.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Navigation between splits is handled by vim-tmux-navigator plugin
-- See lua/custom/plugins/tmux-navigator.lua

-- Save with <leader>w
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite current buffer' })

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_user_command('QfUpdate', function()
  require('inato').update_quickfix()
end, {})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]] (`:Lazy` for status, `:Lazy update` to update)
require('lazy').setup({
  {
    'chrisgrieser/nvim-spider',
    keys = {
      { 'w', "<cmd>lua require('spider').motion('w')<CR>", mode = { 'n', 'o', 'x' } },
      { 'e', "<cmd>lua require('spider').motion('e')<CR>", mode = { 'n', 'o', 'x' } },
      { 'b', "<cmd>lua require('spider').motion('b')<CR>", mode = { 'n', 'o', 'x' } },
    },
  },
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^6', -- Recommended
    ft = { 'haskell', 'lhaskell', 'cabal', 'cabalproject' },
    keys = {
      {
        '<leader>hs',
        function()
          require('haskell-tools').hoogle.hoogle_signature()
        end,
        desc = '[H]oogle [S]ignature',
      },
    },
  },

  {
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
    dependencies = { 'davidmh/cspell.nvim' },
    opts = function(_, opts)
      local cspell = require 'cspell'

      opts.sources = opts.sources or {}

      table.insert(
        opts.sources,
        cspell.diagnostics.with {
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
          end,
        }
      )
      table.insert(opts.sources, cspell.code_actions)
    end,
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'nvim-mini/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    config = function()
      require('oil').setup()
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },

  {
    'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
    opts = {},
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        json = { 'oxfmt' },
        jsonc = { 'oxfmt' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - gsaiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - gsd'   - [S]urround [D]elete [']quotes
      -- - gsr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }

      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'nord',
          globalstatus = true,
          icons_enabled = true,
          component_separators = '',
          section_separators = { left = '\238\130\180', right = '\238\130\182' },
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '\238\130\182' }, right_padding = 2 } },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {
            {
              'filename',
              path = 1,
              fmt = function(str)
                local parts = vim.split(str, '/', { plain = true })
                local keep = 3 -- last dir(s) + filename to show
                if #parts <= keep then
                  return str
                end
                return '.../' .. table.concat(vim.list_slice(parts, #parts - keep + 1), '/')
              end,
            },
          },
          lualine_x = {
            {
              function()
                local reg = vim.fn.reg_recording()
                if reg == '' then
                  return ''
                end
                return 'recording @' .. reg
              end,
              color = { fg = '#f38ba8', gui = 'bold' },
            },
            'filetype',
            'lsp_status',
          },
          lualine_y = { 'progress' },
          lualine_z = { { 'location', separator = { right = '\238\130\180' }, left_padding = 2 } },
        },
        extensions = { 'quickfix', 'lazy', 'oil', 'neo-tree' },
      }

      -- reg_recording() changes don't trigger a statusline redraw on their own
      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = function()
          require('lualine').refresh()
        end,
      })
      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          vim.defer_fn(function()
            require('lualine').refresh()
          end, 50)
        end,
      })
    end,
  },

  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- Auto-imports everything in `lua/custom/plugins/*.lua`
  { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
