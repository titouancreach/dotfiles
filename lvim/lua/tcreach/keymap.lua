-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = ","
-- add your own keymapping

lvim.builtin.which_key.mappings["f"] = { ":Telescope smart_open<CR>", "Smart open" }
lvim.builtin.which_key.mappings["a"] = { ":lua vim.lsp.buf.code_action()<CR>", "Code Action" }
lvim.builtin.which_key.mappings["o"] = { ":Oil<CR>", "Oil" }
lvim.builtin.which_key.mappings["re"] = { "<Plug>RestNvim", "Execute request under cursor" }
lvim.builtin.which_key.mappings["ss"] = { ":Telescope git_status<CR>", "Find dirty files" }

lvim.builtin.which_key.mappings["bc"] = { ":%bd <bar> e# <bar> bd# <CR>", "Close all buffer but this one" };

lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<CR>"

lvim.keys.normal_mode["gh"] = ":lua vim.lsp.buf.hover()<CR>"

lvim.keys.normal_mode["//"] = ":nohlsearch<CR>"
