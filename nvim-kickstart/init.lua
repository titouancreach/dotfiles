-- Personal config based on kickstart.nvim (vim.pack edition).
-- Structure follows upstream's numbered sections; deliberate deviations:
--   - nord + lualine instead of tokyonight + mini.statusline
--   - no Mason: LSP/formatter/linter binaries come from the nix profile
--     (../flake.nix) or workspace node_modules (tsgo, oxlint)
--   - no OS clipboard sync: explicit <leader>y / <leader>Y instead
--   - extra plugins live in lua/custom/plugins/*.lua (auto-loaded)

-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
do
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

  vim.opt.background = 'dark' -- match the dark nord colorscheme

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
end

-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
do
  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- <Esc> in normal mode: clear search highlights and remove all multicursors
  -- (|multicursor|, nvim 0.13). The default <C-L> does both, but <C-l> is
  -- taken by the herdr/tmux split navigation (lua/custom/plugins/tmux-navigator.lua).
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

  -- Navigation between splits is handled by vim-tmux-navigator / herdr
  -- See lua/custom/plugins/tmux-navigator.lua

  -- Save with <leader>w
  vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite current buffer' })

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

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
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then
        output = 'No output from build command.'
      end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then
        return
      end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
          run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
        end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then
          vim.cmd.packadd 'nvim-treesitter'
        end
        vim.cmd 'TSUpdate'
        return
      end

      -- fff.nvim ships a Rust backend: download a prebuilt binary (or build it)
      if name == 'fff.nvim' then
        if not ev.data.active then
          vim.cmd.packadd 'fff.nvim'
        end
        require('fff.download').download_or_build_binary()
        return
      end

      -- firenvim installs its browser-side runtime
      if name == 'firenvim' then
        if not ev.data.active then
          vim.cmd.packadd 'firenvim'
        end
        vim.fn['firenvim#install'](0)
        return
      end
    end,
  })
end

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo)
  return 'https://github.com/' .. repo
end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules, lualine
-- ============================================================
do
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
  -- maintained fork of nord.nvim (shaunsingh's is unmaintained since 2024
  -- and paints DiffAdd/DiffDelete as solid reverse blocks, which breaks
  -- Neogit / codediff line backgrounds)
  vim.pack.add { gh 'gbprod/nord.nvim' }
  require('nord').setup { diff = { mode = 'fg' } } -- 'bg' is reverse-video solid blocks
  vim.cmd.colorscheme 'nord'

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
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?

  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
    gh 'Marskey/telescope-sg',
  }
  if vim.fn.executable 'make' == 1 then
    table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
  end

  -- NOTE: You can install multiple plugins at once
  vim.pack.add(telescope_plugins)

  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    defaults = {
      layout_strategy = 'horizontal',
      layout_config = {
        width = 0.95,
        height = 0.95,
      },
    },
    pickers = {
      -- Default previewers support Tree-sitter.
      find_files = {},
      git_files = {},
      git_status = {
        git_icons = {
          added = '[A]',
          changed = '[M]',
          copied = '[C]',
          deleted = '[D]',
          renamed = '[R]',
          unmerged = '[U]',
          untracked = '[?]',
        },
      },
      live_grep = {},
      grep_string = {},
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
      ast_grep = {
        command = {
          'ast-grep', -- nixpkgs ships only `ast-grep`, no `sg` alias
          '--json=stream',
        }, -- must have --json=stream
        grep_open_files = false, -- search in opened files
        lang = nil, -- string value, specify language for ast-grep `nil` for default
      },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')
  pcall(require('telescope').load_extension, 'ast_grep')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  -- <leader>sf and <leader>/ are handled by fff.nvim (see custom/plugins/fff.lua)
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  -- Resume the last fff picker (files/grep); fall back to Telescope's
  -- resume when fff has nothing saved (help, diagnostics, ...).
  vim.keymap.set('n', '<leader>sr', function()
    if not require('fff').resume() then
      builtin.resume()
    end
  end, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader><space>', builtin.oldfiles, { desc = '[S]earch Recent Files' })
  vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>sc', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [C]onfig files' })

  vim.keymap.set('n', '<leader>sg', ':Telescope ast_grep<CR>', { desc = '[S]earch ast-[Grep]' })
  vim.keymap.set('n', '<leader>st', '<cmd>CodeDiff<CR>', { desc = '[S]earch Git S[t]atus (CodeDiff)' })

  -- It's also possible to pass additional configuration options.
  vim.keymap.set('n', '<leader>s.', function()
    builtin.oldfiles { only_cwd = true }
  end, { desc = '[S]earch Recent Files ("." for repeat)' })

  -- Shortcut for searching your Neovim configuration files
  vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
  end, { desc = '[S]earch [N]eovim files' })

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  -- If you later switch picker plugins, this is where to update these mappings.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for the word under your cursor.
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to the implementation of the word under your cursor.
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to the definition of the word under your cursor.
      --  To jump back, press <C-t>.
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

      -- Fuzzy find all the symbols in your current document.
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

      -- Fuzzy find all the symbols in your current workspace.
      vim.keymap.set('n', 'gW', builtin.lsp_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under your cursor.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration (no Mason: binaries from nix / node_modules)
-- ============================================================
do
  -- [[ LSP Configuration ]]
  --
  -- Binaries (LSP servers, formatters, linters) are NOT managed from nvim:
  -- they come from the nix profile declared in ../flake.nix
  -- (`nix profile add ~/Code/dotfiles`). No Mason.

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
  -- used for completion, annotations and signatures of Neovim apis
  vim.pack.add { gh 'folke/lazydev.nvim' }
  require('lazydev').setup {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
  }

  --  This function gets run when an LSP attaches to a particular buffer:
  --  buffer-local keymaps, reference highlighting, inlay hint toggle.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Highlight references of the word under the cursor on CursorHold,
      -- clear on CursorMoved.
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- Toggle inlay hints, if the language server supports them
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  vim.pack.add { gh 'neovim/nvim-lspconfig' }

  -- Servers whose binary is on $PATH (nix profile, or opam for ocamllsp).
  -- Default cmd/filetypes/root_markers come from nvim-lspconfig's `lsp/` dir.
  --
  -- tsgo (TypeScript 7 native LSP) and oxlint (diagnostics) are configured
  -- further down so they prefer the workspace-pinned node_modules/.bin binary.
  -- oxfmt (formatting) runs through conform, see the formatting section.
  ---@type table<string, vim.lsp.Config>
  local servers = {

    tailwindcss = {},

    ocamllsp = {},

    graphql = {},

    ast_grep = {},

    elmls = {},

    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
          -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    },
  }

  for name, cfg in pairs(servers) do
    if next(cfg) ~= nil then
      vim.lsp.config(name, cfg)
    end
  end
  vim.lsp.enable(vim.tbl_keys(servers))

  -- Servers with a custom cmd (workspace-pinned binaries first)
  -- Prefer the workspace-pinned oxlint (matches what `pnpm lint` runs in CI).
  -- Falls back to `$PATH` oxlint when no workspace binary is found.
  vim.lsp.config('oxlint', {
    cmd = function(dispatchers, config)
      local start = (config and config.root_dir) or vim.fn.getcwd()
      local ws_root = vim.fs.root(start, { 'pnpm-workspace.yaml', 'package.json' }) or start
      local local_bin = ws_root .. '/node_modules/.bin/oxlint'
      local cmd = vim.fn.executable(local_bin) == 1 and local_bin or 'oxlint'
      return vim.lsp.rpc.start({ cmd, '--lsp' }, dispatchers)
    end,
  })
  vim.lsp.enable 'oxlint'

  -- TypeScript 7 (native, Go-based) language server.
  -- Prefer the workspace-pinned binary so the editor uses the exact TS
  -- version the repo/CI pins. Probe `tsgo` (@typescript/native-preview)
  -- BEFORE `tsc`: while a repo is on TS 6 + native-preview, its .bin/tsc
  -- is the old JS compiler with no --lsp mode. On stable TS 7 the native
  -- binary ships as `tsc` and the fallback picks it up.
  vim.lsp.config('tsc', {
    cmd = function(dispatchers, config)
      local start = (config and config.root_dir) or vim.fn.getcwd()
      local ws_root = vim.fs.root(start, { 'pnpm-workspace.yaml', 'package.json', '.git' }) or start
      local cmd = vim
        .iter({ 'tsgo', 'tsc' })
        :map(function(bin)
          return ws_root .. '/node_modules/.bin/' .. bin
        end)
        :find(function(bin)
          return vim.fn.executable(bin) == 1
        end) or 'tsgo'
      return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
    end,
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  })
  vim.lsp.enable 'tsc'

  -- Gleam LSP ships with the compiler (`gleam lsp`). Installed per-project
  -- via nix flakes, so only enable it when the binary is on $PATH — i.e.
  -- when nvim was launched from the project's dev shell.
  if vim.fn.executable 'gleam' == 1 then
    vim.lsp.enable 'gleam'
  end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
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
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
    require('conform').format { async = true, lsp_format = 'fallback' }
  end, { desc = '[F]ormat buffer' })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================
do
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
end

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  -- NOTE: You can also specify a branch or a specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  -- (LaTeX clashes with Vimtex)
  local parsers = {
    'bash',
    'c',
    'cpp',
    'diff',
    'fish',
    'html',
    'java',
    'javascript',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'sql',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
  }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    -- Check if a parser exists and load it
    if not vim.treesitter.language.add(language) then
      return
    end
    -- Enable syntax highlighting and other treesitter features
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds (kept open by default via 'foldenable')
    -- For more info on folds see `:help folds`
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'

    -- Check if treesitter indentation is available for this language, and if so enable it
    -- in case there is no indent query, the indentexpr will fallback to the vim's built in one
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

    -- Enable treesitter based indentation
    if has_indent_query then
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match

      local language = vim.treesitter.language.get_lang(filetype)
      if not language then
        return
      end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable the parser if it is already installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
        require('nvim-treesitter').install(language):await(function()
          treesitter_try_attach(buf, language)
        end)
      else
        -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

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
  -- NOTE: gitsigns (with keymaps) is configured directly in the UI section above

  -- Personal plugins from `lua/custom/plugins/*.lua` (auto-loaded)
  require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
