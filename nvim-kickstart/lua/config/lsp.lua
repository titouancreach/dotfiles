-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration (no Mason: binaries from nix / node_modules)
-- ============================================================
local gh = require('config.pack').gh

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
