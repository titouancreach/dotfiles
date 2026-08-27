return {
  cmd = { 'ast-grep', 'lsp' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'html',
    'css',
    'lua',
    'python',
    'rust',
    'go',
  },
  root_dir = function(bufnr, on_dir)
    local found = vim.fs.find('sgconfig.yml', {
      upward = true,
      path = vim.api.nvim_buf_get_name(bufnr),
    })[1]
    if found then
      on_dir(vim.fs.dirname(found))
    end
  end,
}
