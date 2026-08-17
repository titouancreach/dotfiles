return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Runs whenever an LSP client attaches to a buffer: buffer-local keymaps etc.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- Resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- Highlight references of the word under the cursor on CursorHold,
          -- clear on CursorMoved.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
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
        },
      }

      -- Advertise blink.cmp's extra capabilities to every server.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Servers installed and configured through Mason.
      local servers = {
        -- tsgo (TypeScript 7 native LSP) is configured below, outside of Mason,
        -- so it uses the workspace-pinned @typescript/native-preview binary.
        --
        -- oxlint (diagnostics) is configured below, outside of Mason.
        -- oxfmt (formatting) runs through conform, see init.lua.

        tailwindcss = {},

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

      -- Ensure the servers and tools above are installed (`:Mason` for status)
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'oxfmt', -- Fallback when a project has no node_modules/.bin/oxfmt
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- Servers installed outside of Mason
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

      -- TypeScript 7 (native, Go-based) language server — `tsgo`.
      -- Prefer the workspace-pinned binary (@typescript/native-preview) so the
      -- editor uses the exact TS version the repo/CI pins; fall back to a global
      -- `tsgo` on $PATH. In this monorepo that resolves to TS 7.0.0-dev.
      vim.lsp.config('tsgo', {
        cmd = function(dispatchers, config)
          local start = (config and config.root_dir) or vim.fn.getcwd()
          local ws_root = vim.fs.root(start, { 'pnpm-workspace.yaml', 'package.json', '.git' }) or start
          local local_bin = ws_root .. '/node_modules/.bin/tsgo'
          local cmd = vim.fn.executable(local_bin) == 1 and local_bin or 'tsgo'
          return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
        end,
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
      })
      vim.lsp.enable 'tsgo'
    end,
  },
}
