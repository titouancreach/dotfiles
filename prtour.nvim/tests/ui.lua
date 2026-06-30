-- UI smoke test: render into a real window with folds, add a comment, wire keymaps.
-- nvim --headless -l tests/ui.lua <path-to-diff>
local here = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
local root = vim.fn.fnamemodify(here, ":h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
local review_root = vim.fn.fnamemodify(root, ":h") .. "/review.nvim"
if vim.fn.isdirectory(review_root) == 1 then
  package.path = review_root .. "/lua/?.lua;" .. review_root .. "/lua/?/init.lua;" .. package.path
end

local failures = 0
local function check(name, ok, extra)
  print((ok and "  ok   - " or "  FAIL - ") .. name .. (ok and "" or ("  :: " .. tostring(extra))))
  if not ok then failures = failures + 1 end
end

local diff_path = vim.v.argv[#vim.v.argv]
local fh = io.open(diff_path, "r"); local diff_text = fh:read("*a"); fh:close()

require("prtour").setup({})
local diff = require("prtour.diff")
local ai = require("prtour.ai")
local render = require("prtour.render")
local comments = require("prtour.comments")
local store = require("prtour.store")
local keymaps = require("prtour.keymaps")

local files = diff.parse(diff_text)
local file_index = {}
for _, f in ipairs(files) do file_index[f.path] = f end

-- real window + buffer
vim.cmd("enew")
local win = vim.api.nvim_get_current_win()
local bufnr = vim.api.nvim_get_current_buf()
local session = {
  number = 9000,
  meta = { title = "real PR", additions = 123, deletions = 2, changedFiles = #files, url = "http://x" },
  repo = "cli/cli",
  files = files, file_index = file_index,
  bufnr = bufnr, win = win,
  tour = ai.fallback_tour(files),
}

check("render+folds runs", pcall(function()
  render.render(session)
  comments.render(session)
end))
check("buffer has lines", vim.api.nvim_buf_line_count(bufnr) > 10)

-- add a comment on the first anchored diff line, ensure box renders
local first_anchor_line
for bl, a in pairs(session.anchors) do
  if a and a.file_line then
    if not first_anchor_line or bl < first_anchor_line then first_anchor_line = bl end
  end
end
local a = session.anchors[first_anchor_line]
require("prtour.storage").set_pr("cli/cli", 9000)
store.reset()
store.add(a.path, a.file_line, "issue", "test comment\nsecond line", nil, a.side)
check("comment stored", store.count() == 1)
check("comment box renders", pcall(comments.render, session))

-- keymaps attach without error
check("keymaps setup", pcall(keymaps.setup, session))

-- extmarks present (diff highlights + comment box)
local marks = vim.api.nvim_buf_get_extmarks(bufnr, render.ns, 0, -1, {})
check("render extmarks present", #marks > 0, #marks)
local cmarks = vim.api.nvim_buf_get_extmarks(bufnr, comments.ns, 0, -1, { details = true })
local has_virt = false
for _, m in ipairs(cmarks) do
  if m[4] and m[4].virt_lines then has_virt = true end
end
check("comment virt_lines present", has_virt)

store.clear()
print("")
print(failures == 0 and "ALL PASS" or (failures .. " FAILURE(S)"))
vim.cmd(failures == 0 and "qa!" or "cq")
