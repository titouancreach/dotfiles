
vim.api.nvim_set_keymap("n", ">", "[", { noremap = false })
vim.api.nvim_set_keymap("n", "<", "]", { noremap = false })

vim.api.nvim_set_keymap("n", ">>", ">>", { noremap = false })
vim.api.nvim_set_keymap("n", "<<", "<<", { noremap = false })

vim.api.nvim_set_keymap('n', '//', ':nohl<CR>', { noremap = true, silent = true })


if vim.g.vscode then
    -- VSCode extension
	local vscode = require('vscode')
	vim.keymap.set("n", ">d", function() 
	    vscode.action("editor.action.marker.nextInFiles")
	end)

	vim.keymap.set("n", "<d", function() 
	    vscode.action("editor.action.marker.prevInFiles")
	end)
end


