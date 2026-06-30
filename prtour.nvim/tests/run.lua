-- Headless smoke test:  nvim --headless -l tests/run.lua
-- Adds prtour (and review, if present) to runtimepath, then exercises parsing + render.

local here = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":h")
local root = vim.fn.fnamemodify(here, ":h") -- prtour.nvim/
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
local review_root = vim.fn.fnamemodify(root, ":h") .. "/review.nvim"
if vim.fn.isdirectory(review_root) == 1 then
  package.path = review_root .. "/lua/?.lua;" .. review_root .. "/lua/?/init.lua;" .. package.path
end

local failures = 0
local function check(name, ok, extra)
  if ok then
    print("  ok   - " .. name)
  else
    failures = failures + 1
    print("  FAIL - " .. name .. (extra and ("  :: " .. tostring(extra)) or ""))
  end
end

-- 1. All modules load.
print("== module load ==")
for _, mod in ipairs({
  "prtour.config", "prtour.diff", "prtour.gh", "prtour.storage", "prtour.store",
  "prtour.render", "prtour.comments", "prtour.export", "prtour.ai", "prtour.spinner",
  "prtour.syntax", "prtour.codediff", "prtour.input", "prtour.keymaps", "prtour.review",
  "prtour.tour", "prtour.picker", "prtour",
}) do
  local ok, err = pcall(require, mod)
  check("require " .. mod, ok, err)
end

-- 2. Diff parser.
print("== diff parser ==")
local diff = require("prtour.diff")
local sample = table.concat({
  "diff --git a/src/api.ts b/src/api.ts",
  "index 111..222 100644",
  "--- a/src/api.ts",
  "+++ b/src/api.ts",
  "@@ -10,6 +10,7 @@ export function get() {",
  " const a = 1;",
  "-  return a;",
  "+  return a + 1;",
  "+  // extra",
  " }",
  "diff --git a/go.sum b/go.sum",
  "new file mode 100644",
  "--- /dev/null",
  "+++ b/go.sum",
  "@@ -0,0 +1,2 @@",
  "+dep one",
  "+dep two",
  "",
}, "\n")

local files = diff.parse(sample)
check("two files parsed", #files == 2, #files)
check("file1 path", files[1].path == "src/api.ts", files[1].path)
check("file1 additions", files[1].additions == 2, files[1].additions)
check("file1 deletions", files[1].deletions == 1, files[1].deletions)
check("file2 status added", files[2].status == "added", files[2].status)
check("file2 path", files[2].path == "go.sum", files[2].path)

-- line numbering: the removed line should map to old line 11, added to new line 11.
local h = files[1].hunks[1]
local removed, added
for _, l in ipairs(h.lines) do
  if l.kind == "-" then
    removed = l
  elseif l.kind == "+" and not added then
    added = l
  end
end
check("removed old_lineno == 11", removed and removed.old_lineno == 11, removed and removed.old_lineno)
check("added new_lineno == 11", added and added.new_lineno == 11, added and added.new_lineno)

-- 3. AI fallback tour funnels go.sum into skim.
print("== ai fallback ==")
local ai = require("prtour.ai")
local tour = ai.fallback_tour(files)
check("one main section", #tour.sections == 1, #tour.sections)
check("main has src/api.ts", tour.sections[1].files[1] == "src/api.ts", tour.sections[1].files[1])
check("go.sum in skim", tour.skim[1] == "go.sum", tour.skim and tour.skim[1])

-- 4. Render into a real buffer, check anchors line up with file lines.
print("== render ==")
local render = require("prtour.render")
local bufnr = vim.api.nvim_create_buf(false, true)
local file_index = {}
for _, f in ipairs(files) do
  file_index[f.path] = f
end
local session = {
  number = 1,
  meta = { title = "Test", additions = 2, deletions = 1, changedFiles = 2, url = "" },
  files = files,
  file_index = file_index,
  tour = tour,
  bufnr = bufnr,
  win = nil, -- skip folds in headless
}
render.setup_highlights()
local ok_render, rerr = pcall(render.render, session)
check("render runs", ok_render, rerr)
check("anchors populated", session.anchors ~= nil)
check("section_lines recorded", session.section_lines and #session.section_lines >= 1, session.section_lines and #session.section_lines)
local hdr = vim.api.nvim_buf_get_lines(bufnr, session.section_lines[1] - 1, session.section_lines[1], false)[1]
check("section header has signal circle", hdr and (hdr:match("🔴") or hdr:match("🟡") or hdr:match("⚪")) ~= nil, hdr)

-- Find the anchor for the added line (src/api.ts new line 11) and confirm the
-- buffer text on that line contains the code.
local found = false
for bl, a in pairs(session.anchors or {}) do
  if a and a.path == "src/api.ts" and a.side == "new" and a.file_line == 11 and a.kind == "+" then
    local text = vim.api.nvim_buf_get_lines(bufnr, bl - 1, bl, false)[1]
    found = text and text:match("return a %+ 1")
    break
  end
end
check("added line anchored to correct buffer line", found, "anchor/text mismatch")
check("code_lines recorded for syntax", session.code_lines and #session.code_lines >= 1, session.code_lines and #session.code_lines)
local cl = session.code_lines and session.code_lines[1]
check("code_line has col offset + filetype", cl and cl.col ~= nil and cl.ft ~= nil, cl and (tostring(cl.col) .. "/" .. tostring(cl.ft)))
-- src/api.ts hunk starts at line 10 -> there's a gap above -> an expander.
local n_exp = 0
local exp_sample
for _, e in pairs(session.expanders or {}) do
  n_exp = n_exp + 1
  exp_sample = exp_sample or e
end
check("expander generated for hunk gap", n_exp >= 1 and exp_sample and exp_sample.path == "src/api.ts", exp_sample and exp_sample.path)

-- 5b. PR input parsing (number / url / owner-repo#n).
print("== input parsing ==")
local parse = require("prtour.tour")._parse_input
local p1 = parse("9000")
check("bare number", p1 and p1.number == 9000 and p1.repo == nil, p1 and p1.repo)
local p2 = parse("https://github.com/cli/cli/pull/9000")
check("full url", p2 and p2.number == 9000 and p2.repo == "cli/cli" and p2.ref:match("/pull/9000$") ~= nil, p2 and p2.repo)
local p3 = parse("cli/cli#9000")
check("owner/repo#n", p3 and p3.number == 9000 and p3.repo == "cli/cli", p3 and p3.repo)
local p4 = parse("not-a-pr")
check("garbage -> nil", p4 == nil)
local p5 = parse("https://github.example.com/org/sub-repo/pull/42")
check("enterprise host url", p5 and p5.number == 42 and p5.repo == "org/sub-repo", p5 and p5.repo)

-- 5. Loading view + tour cache round-trip.
print("== loading + cache ==")
check("render_loading runs", pcall(render.render_loading, session))
ai.save_cached("testoid123", tour)
local loaded = ai.load_cached("testoid123")
check("cache round-trips", loaded and loaded.sections ~= nil)
check("cache miss returns nil", ai.load_cached("nope-does-not-exist") == nil)
for _, f in ipairs(vim.fn.glob(vim.fn.stdpath("data") .. "/prtour/tour-*testoid123.json", false, true)) do
  os.remove(f)
end

-- 6. Semantic export labels + GitHub comment rendering.
print("== semantic + github ==")
local store = require("prtour.store")
render.render(session) -- rebuild anchors (the loading test cleared them)
require("prtour.storage").set_pr("o/r", 1)
store.reset()
store.add("src/api.ts", 11, "important", "must fix this", nil, "new")
local md = require("prtour.export").generate_markdown(session)
check("export uses semantic label", md:find("Important:") ~= nil and md:find("%[IMPORTANT%]") == nil, md:match("%d%. .-\n"))

local cm = require("prtour.comments")
session.gh_comments = { { path = "src/api.ts", side = "new", line = 11, body = "nice", author = "octocat" } }
check("render with github comments runs", pcall(cm.render, session))
local cmarks = vim.api.nvim_buf_get_extmarks(bufnr, cm.ns, 0, -1, { details = true })
local has_gh = false
for _, m in ipairs(cmarks) do
  local vl = m[4] and m[4].virt_lines
  if vl then
    for _, line in ipairs(vl) do
      for _, chunk in ipairs(line) do
        if type(chunk[1]) == "string" and chunk[1]:find("@octocat") then has_gh = true end
      end
    end
  end
end
check("github comment box rendered", has_gh)

-- Regression: a GitHub comment with a null/userdata line must not crash render.
session.gh_comments = {
  { path = "src/api.ts", side = "new", line = vim.NIL, body = "outdated", author = "ghost" },
  { path = "src/api.ts", side = "new", line = 11, body = "ok", author = "octocat" },
}
check("render survives null-line github comment", pcall(cm.render, session))

-- Long comments wrap inside the box (no overflow past the right border).
session.gh_comments = nil
store.add("src/api.ts", 11, "suggestion",
  ("word "):rep(60), nil, "new") -- ~300 cols on one logical line
cm.render(session)
local maxw, rows = 0, 0
for _, m in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, cm.ns, 0, -1, { details = true })) do
  local vl = m[4] and m[4].virt_lines
  if vl then
    rows = #vl
    for _, line in ipairs(vl) do
      local w = 0
      for _, ch in ipairs(line) do w = w + vim.fn.strdisplaywidth(ch[1]) end
      maxw = math.max(maxw, w)
    end
  end
end
check("long comment wraps (no overflow)", maxw <= 80 and rows > 3, "maxw=" .. maxw .. " rows=" .. rows)
store.clear()

-- 7. Local mode: header + GitHub-submit guard.
print("== local mode ==")
session.mode = "local"
session.meta = { title = "Local changes · main", additions = 1, deletions = 1, changedFiles = 1, url = "/root" }
render.render(session)
local h1 = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
check("local header (no PR #)", h1:match("Local changes") ~= nil and h1:match("PR #") == nil, h1)
local blocked
local orig_notify = vim.notify
vim.notify = function(m) blocked = m end
require("prtour.review").submit(session, "APPROVE")
vim.notify = orig_notify
check("github submit blocked in local mode", blocked ~= nil and blocked:match("Local review") ~= nil, blocked)

-- 8. Notion ticket: URL extraction + render.
print("== notion ticket ==")
local urls = require("prtour.ai")._notion_urls(
  { body = "Implements https://www.notion.so/inato/Ticket-abc123 .", title = "x", headRefName = "b" })
check("notion url extracted", #urls == 1 and urls[1]:match("notion%.so/inato/Ticket%-abc123") ~= nil, urls[1])
check("no false positive", #require("prtour.ai")._notion_urls({ body = "no link", title = "x" }) == 0)
session.tour = { summary = "s", ticket = { title = "INATO-1 Fix", url = "http://n/x", purpose = "Users could not export." }, sections = {}, skim = {} }
render.render(session)
local has_ticket = false
for _, l in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
  if l:match("🎫 INATO%-1 Fix") then has_ticket = true end
end
check("ticket rendered in tour", has_ticket)

print("")
if failures == 0 then
  print("ALL PASS")
  vim.cmd("qa!")
else
  print(failures .. " FAILURE(S)")
  vim.cmd("cq")
end
