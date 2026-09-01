-- Official Flix plugin: LSP (semantic-token highlighting included) + CLI commands.
-- Needs Java 21+ on $PATH (provided by the project's nix shell) and a
-- `flix.jar` in the project root (next to flix.toml).
vim.pack.add { { src = 'https://github.com/flix/nvim', name = 'flix' } }

require('flix').setup {}
vim.lsp.enable 'flix'
