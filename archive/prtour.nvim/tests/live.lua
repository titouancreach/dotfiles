-- Live test: parse a real diff fixture + run generate_tour through the Claude CLI.
-- Usage: nvim --headless -l tests/live.lua <path-to-diff>
local here = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
local root = vim.fn.fnamemodify(here, ":h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path

local diff_path = vim.v.argv[#vim.v.argv]
local f = io.open(diff_path, "r")
local diff_text = f:read("*a")
f:close()

local diff = require("prtour.diff")
local files = diff.parse(diff_text)
print("parsed files: " .. #files)
for _, file in ipairs(files) do
  -- sanity: every non-binary hunk line has a line number on its side
  local bad = 0
  for _, h in ipairs(file.hunks) do
    for _, l in ipairs(h.lines) do
      if l.kind == "+" and not l.new_lineno then bad = bad + 1 end
      if l.kind == "-" and not l.old_lineno then bad = bad + 1 end
    end
  end
  print(string.format("  %-55s %-9s +%d -%d  hunks=%d badlines=%d",
    file.path, file.status, file.additions, file.deletions, #file.hunks, bad))
end

print("\ncalling claude for tour (this may take ~30s)...")
local ai = require("prtour.ai")
local done = false
ai.generate_tour({ number = 9000, title = "real PR", body = "" }, files, diff_text, function(tour, ai_used)
  print("ai_used: " .. tostring(ai_used))
  print("summary: " .. (tour.summary or ""):sub(1, 200))
  print("sections: " .. #tour.sections)
  for i, s in ipairs(tour.sections) do
    print(string.format("  %d. [%s] %s (%d files)", i, s.signal, s.title, #s.files))
    print("     " .. (s.description or ""):sub(1, 120))
  end
  print("skim: " .. table.concat(tour.skim, ", "))
  done = true
end)

vim.wait(120000, function() return done end)
if not done then
  print("TIMED OUT")
  vim.cmd("cq")
end
vim.cmd("qa!")
