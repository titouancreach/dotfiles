-- ==========================================================================
-- Neovim 0.12 config — no lazy.nvim, using vim.pack + vim.lsp.config/enable
-- ==========================================================================

-- Helper to build GitHub URLs
local gh = function(x)
  return 'https://github.com/' .. x
end

-- [[ Leader ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Options ]]
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.background = 'light'
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣', lead = '·' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldenable = false

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = '[E]xtend [d]iagnostic text' })
vim.api.nvim_set_keymap('n', '>>', '>>', { noremap = false })
vim.api.nvim_set_keymap('n', '<<', '<<', { noremap = false })
vim.keymap.set('v', 'p', '"_dP')
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Yank into " register' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank into " register' })
vim.keymap.set('n', '<leader>Y', function()
  vim.fn.setreg('+', vim.fn.getreg '"')
end, { desc = 'Copy last yanked text to system clipboard' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = '[W]rite current buffer' })

-- [[ Basic Autocommands ]]
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

-- ==========================================================================
-- [[ Plugin Installation via vim.pack ]]
-- ==========================================================================

-- Build hooks for plugins that need post-install steps
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end
    if name == 'telescope-fzf-native.nvim' then
      vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    end
    if name == 'LuaSnip' then
      vim.system({ 'make', 'install_jsregexp' }, { cwd = ev.data.path }):wait()
    end
    if name == 'nvim-treesitter' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
    end
  end,
})

vim.pack.add {
  -- Colorscheme (loaded first)
  gh 'catppuccin/nvim',

  -- Core dependencies
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
  gh 'nvim-tree/nvim-web-devicons',
  { src = gh 'echasnovski/mini.icons', name = 'mini.icons' },

  -- UI
  gh 'folke/snacks.nvim',
  gh 'folke/which-key.nvim',
  gh 'folke/noice.nvim',
  gh 'rcarriga/nvim-notify',
  gh 'nvim-lualine/lualine.nvim',
  gh 'sphamba/smear-cursor.nvim',
  gh 'stevearc/stickybuf.nvim',

  -- Telescope
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-fzf-native.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'Marskey/telescope-sg',

  -- Treesitter
  gh 'nvim-treesitter/nvim-treesitter',

  -- Completion & Snippets
  { src = gh 'saghen/blink.cmp', version = vim.version.range '1.0' },
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.0' },
  gh 'rafamadriz/friendly-snippets',
  gh 'folke/lazydev.nvim',

  -- LSP tooling
  gh 'mason-org/mason.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'j-hui/fidget.nvim',

  -- Formatting & Linting
  gh 'stevearc/conform.nvim',
  gh 'nvimtools/none-ls.nvim',
  gh 'davidmh/cspell.nvim',

  -- Git
  gh 'lewis6991/gitsigns.nvim',
  gh 'NeogitOrg/neogit',
  gh 'esmuellert/codediff.nvim',
  gh 'pwntester/octo.nvim',

  -- Navigation & Motion
  gh 'folke/flash.nvim',
  gh 'christoomey/vim-tmux-navigator',
  gh 'chrisgrieser/nvim-spider',

  -- Editing
  gh 'windwp/nvim-autopairs',
  gh 'jake-stewart/multicursor.nvim',
  gh 'monaqa/dial.nvim',
  gh 'echasnovski/mini.nvim',
  { src = gh 'echasnovski/mini.bracketed', name = 'mini.bracketed' },
  { src = gh 'echasnovski/mini.hipatterns', name = 'mini.hipatterns' },
  gh 'tpope/vim-abolish',
  gh 'NMAC427/guess-indent.nvim',
  gh 'max397574/better-escape.nvim',

  -- File browsing
  gh 'stevearc/oil.nvim',
  gh 'nvim-neo-tree/neo-tree.nvim',

  -- Testing
  gh 'nvim-neotest/neotest',
  gh 'benelan/neotest-vitest',
  gh 'nvim-neotest/nvim-nio',

  -- Misc
  gh 'folke/todo-comments.nvim',
  gh 'andrewferrier/debugprint.nvim',
  gh 'dmmulroy/tsc.nvim',
  gh 'mrcjkb/haskell-tools.nvim',
  gh 'greggh/claude-code.nvim',
  gh 'glacambre/firenvim',
  gh 'MeanderingProgrammer/render-markdown.nvim',
}

-- Local plugin: review.nvim
vim.opt.rtp:prepend(vim.fn.expand '~/Code/dotfiles/review.nvim')

-- ==========================================================================
-- [[ Plugin Configuration ]]
-- ==========================================================================

-- Colorscheme
require('catppuccin').setup { show_end_of_buffer = true }
vim.cmd 'colorscheme catppuccin-mocha'

-- Snacks
require('snacks').setup {
  bigfile = { enabled = true },
  styles = { preview = { treesitter = { enabled = true } } },
  dashboard = {
    preset = { pick = nil },
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1, limit = 9 },
    },
  },
  explorer = { enabled = false },
  indent = { enabled = false },
  input = { enabled = true },
  browse = { enabled = true },
  notifier = { enabled = true },
  gitbrowse = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  zen = { enabled = true },
  gh = { enabled = true },
  picker = {
    formatters = { file = { filename_first = true } },
    preview = { treesitter = { enabled = true } },
    win = { preview = { treesitter = { enabled = true } } },
    sources = { gh_issue = {}, gh_pr = {} },
  },
}

vim.api.nvim_create_user_command('GitLink', function(cmd_opts)
  require('snacks').gitbrowse {
    branch = 'main',
    line_start = cmd_opts.line1,
    line_end = cmd_opts.line2,
    open = function(url)
      vim.fn.setreg('+', url)
      vim.notify("Copied 'main' link to clipboard", vim.log.levels.INFO, { title = 'Snacks' })
    end,
  }
end, { desc = 'Create GitHub link to current line or visual selection', range = true })

vim.keymap.set('n', '<leader>gi', function()
  Snacks.picker.gh_issue()
end, { desc = 'GitHub Issues (open)' })
vim.keymap.set('n', '<leader>gI', function()
  Snacks.picker.gh_issue { state = 'all' }
end, { desc = 'GitHub Issues (all)' })
vim.keymap.set('n', '<leader>gp', function()
  Snacks.picker.gh_pr()
end, { desc = 'GitHub Pull Requests (open)' })
vim.keymap.set('n', '<leader>gP', function()
  Snacks.picker.gh_pr { state = 'all' }
end, { desc = 'GitHub Pull Requests (all)' })
vim.keymap.set('n', '<leader>.', function()
  Snacks.scratch()
end, { desc = 'Toggle Scratch Buffer' })
vim.keymap.set('n', '<leader>S', function()
  Snacks.scratch.select()
end, { desc = 'Select Scratch Buffer' })

-- Which-key
require('which-key').setup {
  delay = 0,
  icons = {
    mappings = vim.g.have_nerd_font,
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
  spec = {
    { '<leader>s', group = '[S]earch' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
  },
}

-- Noice
require('noice').setup {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
  notify = { enabled = false },
}

-- Lualine
require('lualine').setup {
  sections = {
    lualine_a = { 'mode', 'branch' },
    lualine_b = { 'diff', 'diagnostics' },
    lualine_c = { { 'filename', path = 1 } },
    lualine_x = { { 'fileformat', 'filetype', 'lsp_status' } },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  extensions = { 'quickfix', 'oil' },
}

-- Smear cursor
require('smear_cursor').setup {
  smear_between_buffers = true,
  smear_between_neighbor_lines = true,
  smear_insert_mode = true,
}

-- Stickybuf
require('stickybuf').setup {}

-- Telescope
local telescope = require 'telescope'
local builtin = require 'telescope.builtin'

telescope.setup {
  defaults = {
    layout_strategy = 'horizontal',
    layout_config = { width = 0.95, height = 0.95 },
  },
  pickers = {
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
    ast_grep = {
      command = { 'sg', '--json=stream' },
      grep_open_files = false,
      lang = nil,
    },
  },
}

pcall(telescope.load_extension, 'fzf')
pcall(telescope.load_extension, 'ui-select')
pcall(telescope.load_extension, 'ast_grep')

vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.git_files, { desc = '[S]earch Git [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader><space>', builtin.oldfiles, { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sc', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [C]onfig files' })
vim.keymap.set('n', '<leader>sg', ':Telescope ast_grep<CR>', { desc = '[S]earch ast-[Grep]' })
vim.keymap.set('n', '<leader>st', '<cmd>CodeDiff<CR>', { desc = '[S]earch Git S[t]atus (CodeDiff)' })
vim.keymap.set('n', '<leader>s.', function()
  builtin.oldfiles { only_cwd = true }
end, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- Treesitter
require('nvim-treesitter').setup()

local ts_languages = {
  'bash', 'c', 'cpp', 'fish', 'html', 'java', 'javascript',
  'lua', 'markdown', 'markdown_inline', 'python', 'sql',
  'vimscript', 'vimdoc', 'tsx', 'typescript',
}

local ts_filetypes = {}
for _, lang in ipairs(ts_languages) do
  for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
    table.insert(ts_filetypes, ft)
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = ts_filetypes,
  callback = function()
    vim.treesitter.start()
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
  end,
})

-- Completion (blink.cmp)
require('blink.cmp').setup {
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'lazydev' },
    providers = {
      lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
    },
  },
  snippets = { preset = 'luasnip' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}

-- LuaSnip
require('luasnip.loaders.from_vscode').lazy_load()
local standalone_snippets = {
  '~/Code/Inato/inato-marketplace/.vscode/effect.code-snippets',
  '~/Code/Inato/inato-marketplace/.vscode/icon.code-snippets',
  '~/Code/Inato/inato-marketplace/.vscode/inato.code-snippets',
  '~/Code/Inato/inato-marketplace/.vscode/story.code-snippets',
  '~/Code/Inato/inato-marketplace/.vscode/storydoc.code-snippets',
}
for _, path in ipairs(standalone_snippets) do
  pcall(require('luasnip.loaders.from_vscode').load_standalone, { path = path })
end

-- Lazydev
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

-- Mason
require('mason').setup {
  install_root_dir = vim.fn.expand '~/.local/share/nvim-kickstart/mason',
}
require('mason-tool-installer').setup {
  ensure_installed = {
    'tsgo',
    'biome',
    'tailwindcss-language-server',
    'graphql-language-service-cli',
    'ast-grep',
    'elm-language-server',
    'lua-language-server',
    'stylua',
  },
}

-- Fidget
require('fidget').setup {}

-- Conform (formatting)
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    typescript = { 'biome', 'biome-organize-imports' },
    typescriptreact = { 'biome', 'biome-organize-imports' },
    json = { 'biome' },
  },
}

vim.keymap.set('', '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat buffer' })

-- None-ls (cspell)
local cspell = require 'cspell'
require('null-ls').setup {
  sources = {
    cspell.diagnostics.with {
      diagnostics_postprocess = function(diagnostic)
        diagnostic.severity = vim.diagnostic.severity.HINT
      end,
    },
    cspell.code_actions,
  },
}

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

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

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
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
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
}

vim.keymap.set('n', '<leader>hq', '<cmd>Gitsigns setqflist<CR>', { desc = 'git show hunks in [Q]uicklist' })

-- Neogit
require('neogit').setup { diff_viewer = 'codediff' }
vim.keymap.set('n', '<leader>hg', '<cmd>Neogit<CR>', { desc = 'Open Neo[g]it' })

vim.api.nvim_create_user_command('AddClaudeAsCoAuthor', function()
  local line = 'Co-Authored-By: Claude <noreply@anthropic.com>'
  vim.api.nvim_put({ '', line }, 'l', true, true)
end, { desc = 'Add Claude as commit co-author' })

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NeogitCommitMessage',
  callback = function()
    vim.keymap.set('n', '<leader>hc', '<cmd>AddClaudeAsCoAuthor<CR>', { buffer = true, desc = 'Add [C]laude as co-author' })
  end,
})

-- Codediff
require('codediff').setup {}

-- Octo
require('octo').setup { picker = 'telescope', enable_builtin = true }
vim.keymap.set('n', '<leader>oi', '<CMD>Octo issue list<CR>', { desc = 'List GitHub Issues' })
vim.keymap.set('n', '<leader>op', '<CMD>Octo pr list<CR>', { desc = 'List GitHub PullRequests' })
vim.keymap.set('n', '<leader>od', '<CMD>Octo discussion list<CR>', { desc = 'List GitHub Discussions' })
vim.keymap.set('n', '<leader>on', '<CMD>Octo notification list<CR>', { desc = 'List GitHub Notifications' })
vim.keymap.set('n', '<leader>os', function()
  require('octo.utils').create_base_search_command { include_current_repo = true }
end, { desc = 'Search GitHub' })

-- Flash
require('flash').setup {
  label = { rainbow = { enabled = true, shade = 2 } },
  modes = { search = { enabled = true }, char = { jump_labels = true } },
}
vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
  require('flash').jump()
end, { desc = 'Flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function()
  require('flash').treesitter()
end, { desc = 'Flash Treesitter' })
vim.keymap.set('o', 'r', function()
  require('flash').remote()
end, { desc = 'Remote Flash' })
vim.keymap.set({ 'o', 'x' }, 'R', function()
  require('flash').treesitter_search()
end, { desc = 'Treesitter Search' })
vim.keymap.set('c', '<c-s>', function()
  require('flash').toggle()
end, { desc = 'Toggle Flash Search' })

-- Tmux navigator
vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { desc = 'Navigate Left (tmux-aware)' })
vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { desc = 'Navigate Down (tmux-aware)' })
vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { desc = 'Navigate Up (tmux-aware)' })
vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { desc = 'Navigate Right (tmux-aware)' })

-- Spider (smart word motions)
vim.keymap.set({ 'n', 'o', 'x' }, 'w', "<cmd>lua require('spider').motion('w')<CR>")
vim.keymap.set({ 'n', 'o', 'x' }, 'e', "<cmd>lua require('spider').motion('e')<CR>")
vim.keymap.set({ 'n', 'o', 'x' }, 'b', "<cmd>lua require('spider').motion('b')<CR>")

-- Autopairs
require('nvim-autopairs').setup {}

-- Multicursor
local mc = require 'multicursor-nvim'
mc.setup()
vim.keymap.set('n', '<leader>gv', mc.restoreCursors)
vim.keymap.set({ 'n', 'x' }, '<up>', function()
  mc.lineAddCursor(-1)
end)
vim.keymap.set({ 'n', 'x' }, '<down>', function()
  mc.lineAddCursor(1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader><up>', function()
  mc.lineSkipCursor(-1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader><down>', function()
  mc.lineSkipCursor(1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader>n', function()
  mc.matchAddCursor(1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader>s', function()
  mc.matchSkipCursor(1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader>N', function()
  mc.matchAddCursor(-1)
end)
vim.keymap.set({ 'n', 'x' }, '<leader>S', function()
  mc.matchSkipCursor(-1)
end)
vim.keymap.set('n', '<c-leftmouse>', mc.handleMouse)
vim.keymap.set('n', '<c-leftdrag>', mc.handleMouseDrag)
vim.keymap.set('n', '<c-leftrelease>', mc.handleMouseRelease)
vim.keymap.set({ 'n', 'x' }, '<c-q>', mc.toggleCursor)
mc.addKeymapLayer(function(layerSet)
  layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
  layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)
  layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)
  layerSet('n', '<esc>', function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)
local hl = vim.api.nvim_set_hl
hl(0, 'MultiCursorCursor', { reverse = true })
hl(0, 'MultiCursorVisual', { link = 'Visual' })
hl(0, 'MultiCursorSign', { link = 'SignColumn' })
hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
hl(0, 'MultiCursorDisabledCursor', { reverse = true })
hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })

-- Dial (increment/decrement)
local augend = require 'dial.augend'
require('dial.config').augends:register_group {
  default = {
    augend.integer.alias.decimal,
    augend.integer.alias.hex,
    augend.date.alias['%Y/%m/%d'],
    augend.constant.alias.bool,
  },
}
vim.keymap.set('n', '<C-a>', function()
  require('dial.map').manipulate('increment', 'normal')
end)
vim.keymap.set('n', '<C-x>', function()
  require('dial.map').manipulate('decrement', 'normal')
end)
vim.keymap.set('n', 'g<C-a>', function()
  require('dial.map').manipulate('increment', 'gnormal')
end)
vim.keymap.set('n', 'g<C-x>', function()
  require('dial.map').manipulate('decrement', 'gnormal')
end)
vim.keymap.set('x', '<C-a>', function()
  require('dial.map').manipulate('increment', 'visual')
end)
vim.keymap.set('x', '<C-x>', function()
  require('dial.map').manipulate('decrement', 'visual')
end)
vim.keymap.set('x', 'g<C-a>', function()
  require('dial.map').manipulate('increment', 'gvisual')
end)
vim.keymap.set('x', 'g<C-x>', function()
  require('dial.map').manipulate('decrement', 'gvisual')
end)

-- Mini.nvim (ai + surround)
require('mini.ai').setup { n_lines = 500 }
require('mini.surround').setup {
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  },
}

-- Mini.bracketed
require('mini.bracketed').setup {
  comment = { suffix = '' },
}

local bracket_targets = {
  { 'b', 'buffer' },
  { 'x', 'conflict' },
  { 'd', 'diagnostic' },
  { 'f', 'file' },
  { 'i', 'indent' },
  { 'j', 'jump' },
  { 'l', 'location' },
  { 'o', 'oldfile' },
  { 'q', 'quickfix' },
  { 't', 'treesitter' },
  { 'u', 'undo' },
  { 'w', 'window' },
  { 'y', 'yank' },
}

for _, target in ipairs(bracket_targets) do
  local suffix, name = target[1], target[2]
  vim.keymap.set('n', '<' .. suffix, ']' .. suffix, { desc = 'Next ' .. name, remap = true })
  vim.keymap.set('n', '<' .. suffix:upper(), ']' .. suffix:upper(), { desc = 'Last ' .. name, remap = true })
  vim.keymap.set('n', '>' .. suffix, '[' .. suffix, { desc = 'Previous ' .. name, remap = true })
  vim.keymap.set('n', '>' .. suffix:upper(), '[' .. suffix:upper(), { desc = 'First ' .. name, remap = true })
end

-- Guess indent
require('guess-indent').setup {}

-- Better escape
require('better_escape').setup()

-- Oil
require('oil').setup()
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- Neo-tree
require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window',
        ['Y'] = function(state)
          local node = state.tree:get_node()
          if not node or not node.id then
            vim.notify('No node selected.', vim.log.levels.WARN)
            return
          end
          if vim.fn.has 'clipboard' == 0 then
            vim.notify('System clipboard is not available.', vim.log.levels.ERROR)
            return
          end
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify
          local choices = {
            { label = 'Absolute path', value = filepath },
            { label = 'Path relative to CWD', value = modify(filepath, ':.') },
            { label = 'Path relative to HOME', value = modify(filepath, ':~') },
            { label = 'Filename', value = filename },
            { label = 'Filename without extension', value = modify(filename, ':r') },
            { label = 'Extension of the filename', value = modify(filename, ':e') },
          }
          vim.ui.select(choices, {
            prompt = 'Choose to copy to clipboard:',
            format_item = function(item)
              return string.format('%-30s %s', item.label, item.value)
            end,
          }, function(choice)
            if not choice then
              vim.notify('Copy cancelled.', vim.log.levels.INFO)
              return
            end
            vim.fn.setreg('+', choice.value)
            vim.notify('Copied to clipboard: ' .. choice.value)
          end)
        end,
      },
    },
  },
  window = { width = 70 },
}
vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })

-- Neotest
require('neotest').setup {
  adapters = { require 'neotest-vitest' },
}
vim.keymap.set('n', '<leader>twr', function()
  require('neotest').run.run { vitestCommand = 'vitest --watch' }
end, { desc = 'Run Watch' })
vim.keymap.set('n', '<leader>twf', function()
  require('neotest').run.run { vim.fn.expand '%', vitestCommand = 'vitest --watch' }
end, { desc = 'Run Watch File' })

-- Todo comments
require('todo-comments').setup { signs = false }

-- Debugprint
require('debugprint').setup()
vim.keymap.set('n', '<leader>dv', '', {
  callback = function()
    require('debugprint').debugprint { variable = true }
  end,
  desc = '[D]ebug [v]ariable with console.log',
})
vim.keymap.set('n', '<leader>dp', '', {
  callback = function()
    require('debugprint').debugprint {}
  end,
  desc = '[D]ebug [p]lain with console.log',
})
vim.keymap.set('n', '<leader>dj', 'ciwJSON.stringify(<esc>pa, null, 2)<esc>', { desc = '[D]ebug log for [J]SON-like value' })

-- TSC
require('tsc').setup()
vim.keymap.set('n', '<leader>to', ':TSCOpen<CR>', { desc = '[O]pen TSC window' })
vim.keymap.set('n', '<leader>tc', ':TSCClose<CR>', { desc = '[C]lose TSC window' })
vim.keymap.set('n', '<leader>tt', ':TSC<CR>', { desc = '[T]SC' })

-- Haskell tools (auto-configures, no explicit setup needed)

-- Claude code
require('claude-code').setup()

-- Firenvim
vim.g.firenvim_config = {
  globalSettings = { alt = 'all' },
  localSettings = { ['.*'] = { takeover = 'never' } },
}
if vim.g.started_by_firenvim then
  vim.o.laststatus = 0
  vim.o.guifont = 'monospace:h14'
end

-- Render markdown
require('render-markdown').setup {}

-- Review (local plugin)
pcall(function()
  require('review').setup {}
end)

-- ==========================================================================
-- [[ Neovim 0.12 built-in LSP configuration ]]
-- ==========================================================================

-- Broadcast blink.cmp capabilities to all LSP servers
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Enable all LSP servers (configs in lsp/*.lua)
vim.lsp.enable {
  'tsgo',
  'biome',
  'tailwindcss',
  'graphql',
  'oxc',
  'ast_grep',
  'elmls',
  'lua_ls',
}

-- LSP attach autocommand
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- grn (rename) and gra (code action) are built-in in Neovim 0.12

    -- Override built-in LSP keymaps with Telescope pickers
    map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
    map('gW', require('telescope.builtin').lsp_workspace_symbols, 'Open Workspace Symbols')
    map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Diagnostic Config
vim.diagnostic.config {
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
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
