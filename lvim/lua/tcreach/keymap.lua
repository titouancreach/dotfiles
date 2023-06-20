-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader = ","

-- add your own keymapping

lvim.builtin.which_key.mappings["f"] = { ":Telescope smart_open<CR>", "Smart open" }
lvim.builtin.which_key.mappings["a"] = { ":lua vim.lsp.buf.code_action()<CR>", "Code Action" }
lvim.builtin.which_key.mappings["o"] = { ":Oil<CR>", "Oil" }
lvim.builtin.which_key.mappings["ss"] = { ":Telescope git_status<CR>", "Find dirty files" }

lvim.builtin.which_key.mappings["bc"] = { ":%bd <bar> e# <bar> bd# <CR>", "Close all buffer but this one" };

lvim.builtin.which_key.mappings["r"] = {
    name = "Replace",
    r = { "<cmd>lua require('spectre').open()<cr>", "Open spectre" },
    w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Open spectre with current word" },
    f = { "<cmd>lua require('spectre').open_file_search()<cr>", "Spectre in current buffer" },
}

lvim.builtin.which_key.mappings["z"] = {
    name = "Execute",
    e = { "<Plug>RestNvim", "Execute request under cursor" },
}

lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<CR>"

lvim.keys.normal_mode["gh"] = ":lua vim.lsp.buf.hover()<CR>"

lvim.keys.normal_mode["//"] = ":nohlsearch<CR>"
