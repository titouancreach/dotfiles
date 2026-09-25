-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules, lualine
-- ============================================================
local gh = require('config.pack').gh

-- Automatically detect and set indentation
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- Adds git related signs to the gutter, as well as utilities for managing changes
-- See `:help gitsigns` to understand what each configuration key does.
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
  -- Inline blame at end of the current line, like VSCode/GitLens.
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 300,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '  <author>, <author_time:%R> · <summary>',
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    -- Toggles
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
}

-- Global gitsigns keymaps (not buffer-local)
vim.keymap.set('n', '<leader>hq', '<cmd>Gitsigns setqflist<CR>', { desc = 'git show hunks in [Q]uicklist' })
vim.keymap.set('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = 'git [t]oggle line [b]lame' })
-- Change navigation, AZERTY convention: < = next, > = previous (matches bracketed.lua).
-- In a diff window use builtin ]c/[c; in a normal buffer use gitsigns hunks.
vim.keymap.set('n', '<c', function()
  if vim.wo.diff then
    vim.cmd.normal { ']c', bang = true }
  else
    require('gitsigns').nav_hunk 'next'
  end
end, { desc = 'git next hunk/change' })
vim.keymap.set('n', '>c', function()
  if vim.wo.diff then
    vim.cmd.normal { '[c', bang = true }
  else
    require('gitsigns').nav_hunk 'prev'
  end
end, { desc = 'git previous hunk/change' })

-- Useful plugin to show you pending keybinds.
vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  -- Delay between pressing a key and opening which-key (milliseconds)
  delay = 0,
  icons = {
    -- set icon mappings to true if you have a Nerd Font
    mappings = vim.g.have_nerd_font,
    -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
    -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },
  -- Document existing key chains
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}

-- [[ Colorscheme ]]
vim.pack.add { { src = gh 'rose-pine/neovim', name = 'rose-pine' } }
require('rose-pine').setup {
  variant = 'moon',
  dark_variant = 'moon',
  styles = { italic = false },
  highlight_groups = {
    -- listchars (lead/trail dots): rose-pine's default `muted` is too loud
    Whitespace = { fg = 'highlight_med' },
    NonText = { fg = 'highlight_med' },
  },
}
vim.cmd.colorscheme 'rose-pine-moon'

-- Highlight todo, notes, etc in comments
vim.pack.add { gh 'nvim-lua/plenary.nvim', gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }

-- [[ mini.nvim ]]
--  A collection of various small independent plugins/modules
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- Pretty icons for oil.nvim (other plugins use nvim-web-devicons directly)
require('mini.icons').setup()

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
-- NOTE: upstream uses the default `sa`/`sd`/`sr` mappings, but `s` belongs
-- to flash.nvim here, so keep the old kickstart `gs` prefix.
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

-- Statusline: lualine instead of upstream's mini.statusline
vim.pack.add { gh 'nvim-tree/nvim-web-devicons', gh 'nvim-lualine/lualine.nvim' }
require('lualine').setup {
  options = {
    theme = 'rose-pine',
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
  extensions = { 'quickfix', 'oil', 'neo-tree' },
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
