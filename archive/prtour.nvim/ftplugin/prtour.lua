-- Settings for the PR tour buffer (a read-only, narrated-diff "special" buffer).
-- Crucially this pins manual folding so it never inherits the user's global
-- treesitter `foldmethod=expr` (which has no parser for this filetype).
local o = vim.opt_local

o.buftype = "nofile"
o.swapfile = false
o.bufhidden = "hide"

-- Folding: section folds are created manually by render.lua.
o.foldmethod = "manual"
o.foldexpr = ""
o.foldenable = true
o.foldlevel = 99
o.foldcolumn = "1"

-- Display.
o.wrap = false
o.number = false
o.relativenumber = false
o.signcolumn = "yes"
o.cursorline = true
o.list = false
o.spell = false
o.colorcolumn = ""
