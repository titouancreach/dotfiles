-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
--lvim.leader = "<SPACE>"

-- add your own keymapping

lvim.builtin.which_key.mappings["f"] = { ":Telescope smart_open<CR>", "Smart open" }
lvim.builtin.which_key.mappings["a"] = { ":lua vim.lsp.buf.code_action()<CR>", "Code Action" }
lvim.builtin.which_key.mappings["o"] = { ":Oil<CR>", "Oil" }
lvim.builtin.which_key.mappings["ss"] = { ":Telescope git_status<CR>", "Find dirty files" }

lvim.builtin.which_key.mappings["bc"] = { ":BufOnly<CR>", "Close all buffer but this one" };

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

lvim.builtin.which_key.mappings["gd"] = {
    ":DiffviewOpen<CR>", "Open DiffView"
}

lvim.builtin.which_key.mappings["gg"] = {
    ":Neogit<CR>", "Open Neogit"
}

lvim.keys.normal_mode["//"] = ":nohlsearch<CR>"

lvim.keys.visual_mode["J"] = ":m '>+1<CR>gv=gv"
lvim.keys.visual_mode["K"] = ":m '<-2<CR>gv=gv"

lvim.keys.normal_mode["j"] = "gj"
lvim.keys.normal_mode["k"] = "gk"

lvim.keys.normal_mode["0"] = "^"

lvim.keys.normal_mode["gvd"] = ":vsp<CR>gd" -- Goto Vertical Definition
lvim.keys.normal_mode["ghd"] = ":sp<CR>gd"  -- Goto Horizontal Definition

lvim.builtin.terminal.open_mapping = "<C-t>"
lvim.builtin.terminal.direction = "horizontal"
vim.api.nvim_set_keymap("t", "<C-@>", "<C-\\><C-n>", { noremap = true })

-- lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<CR>"
