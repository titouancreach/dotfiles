return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'Marskey/telescope-sg' },
    },
    config = function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'

      -- Setup telescope with treesitter highlighting in preview
      telescope.setup {
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = {
            width = 0.95,
            height = 0.95,
          },
        },
        pickers = {
          find_files = {
            previewer = require('telescope.previewers').vim_buffer_cat.new {},
          },
          git_files = {
            previewer = require('telescope.previewers').vim_buffer_cat.new {},
          },
          live_grep = {
            previewer = require('telescope.previewers').vim_buffer_vimgrep.new {},
          },
          grep_string = {
            previewer = require('telescope.previewers').vim_buffer_vimgrep.new {},
          },
        },
        extensions = {
          ast_grep = {
            command = {
              'sg', -- For Linux, use `ast-grep` instead of `sg`
              '--json=stream',
            }, -- must have --json=stream
            grep_open_files = false, -- search in opened files
            lang = nil, -- string value, specify language for ast-grep `nil` for default
          },
        },
      }

      -- Load extensions
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      pcall(telescope.load_extension, 'ast_grep')

      -- Keybindings
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

      -- It's also possible to pass additional configuration options.
      vim.keymap.set('n', '<leader>s.', function()
        builtin.oldfiles { only_cwd = true }
      end, { desc = '[S]earch Recent Files ("." for repeat)' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
