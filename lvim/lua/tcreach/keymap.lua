-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>

-- lvim.leader = "<SPACE>"

-- add your own keymapping

lvim.builtin.which_key.mappings["f"] = { ":Telescope smart_open<CR>", "Smart open" }
lvim.builtin.which_key.mappings["a"] = { ":lua vim.lsp.buf.code_action()<CR>", "Code Action" }
lvim.builtin.which_key.mappings["o"] = { ":Oil<CR>", "Oil" }
lvim.builtin.which_key.mappings["ss"] = { ":Telescope git_status<CR>", "Find dirty files" }

lvim.builtin.which_key.mappings["bc"] = { ":BufOnly<CR>", "Close all buffer but this one" };

lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }

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

lvim.builtin.terminal.open_mapping = "<C-t>"
lvim.builtin.terminal.direction = "horizontal"

vim.api.nvim_set_keymap("t", "<C-@>", "<C-\\><C-n>", { noremap = true })

lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers<CR>"

vim.api.nvim_set_keymap("n", ">", "[", { noremap = false })
vim.api.nvim_set_keymap("n", "<", "]", { noremap = false })

-- vim.api.nvim_set_keymap("o", "<", "]", { noremap = false })
-- vim.api.nvim_set_keymap("o", ">", "[", { noremap = false })
-- vim.api.nvim_set_keymap("x", "<", "]", { noremap = false })
-- vim.api.nvim_set_keymap("x", ">", "[", { noremap = false })
--
vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", { noremap = true })
