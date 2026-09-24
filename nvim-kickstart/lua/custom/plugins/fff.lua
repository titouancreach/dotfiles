-- fff.nvim: frecency-ranked file finder with a Rust backend.
-- The binary is downloaded/built by the PackChanged hook in init.lua.
-- Loaded at startup so frecency tracking sees every file you open.
vim.pack.add { 'https://github.com/dmtrKovalenko/fff.nvim' }

require('fff').setup {}

-- In an oil buffer, prefill the query with the displayed directory (relative
-- to cwd) so the picker is scoped to it: fff treats a `dir/` token as a
-- path constraint. `opts.cwd` doesn't scope anything, it keeps the cwd index.
local function oil_scope(opts)
  opts = opts or {}
  if vim.bo.filetype ~= 'oil' then
    return opts
  end
  local dir = require('oil').get_current_dir()
  local cwd = vim.fs.normalize(vim.uv.cwd()) .. '/'
  dir = dir and vim.fs.normalize(dir) .. '/'
  if dir and dir ~= cwd and vim.startswith(dir, cwd) then
    opts.query = dir:sub(#cwd + 1) .. ' '
  end
  return opts
end

-- Replaces Telescope's git_files file finder.
vim.keymap.set('n', '<leader>sf', function()
  require('fff').find_files(oil_scope())
end, { desc = '[S]earch [F]iles (fff)' })
-- Replaces Telescope's live_grep.
vim.keymap.set('n', '<leader>/', function()
  require('fff').live_grep(oil_scope())
end, { desc = '[S]earch by Grep (fff)' })
