-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
local gh = require('config.pack').gh

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
