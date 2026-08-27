return {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  filetypes = { 'graphql', 'typescriptreact', 'javascriptreact' },
  root_markers = { '.graphqlrc', '.graphqlrc.yml', '.graphqlrc.yaml', '.graphqlrc.json', 'graphql.config.js', 'graphql.config.ts' },
}
