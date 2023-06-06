-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = ","
-- add your own keymapping

-- ,f = :Telescope git_files
lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<CR>"
lvim.keys.normal_mode["<leader>a"] = ":lua vim.lsp.buf.code_action()<CR>"
lvim.keys.normal_mode["gh"] = ":lua vim.lsp.buf.hover()<CR>"
lvim.keys.normal_mode["<leader>sp"] = ":Telescope projects<CR>"
lvim.keys.normal_mode["<leader>s;"] = ":Telescope lsp_references<CR>"
lvim.keys.normal_mode["<leader>ss"] = ":Telescope git_status<CR>"

lvim.keys.normal_mode["//"] = ":nohlsearch<CR>"

lvim.keys.normal_mode["<leader>bp"] = ":lua require('dap').toggle_breakpoint()<CR>"
lvim.keys.normal_mode["<F5>"] = ":lua require('dap').continue()<CR>"

lvim.keys.normal_mode["<leader>re"] = "<Plug>RestNvim"
lvim.keys.normal_mode["<leader>o"] = ":Oil<CR>"
