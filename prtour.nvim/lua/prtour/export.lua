-- Export comments to clipboard markdown, and yank a code-context block.
local M = {}

local store = require("prtour.store")

---@param c PrComment
---@return string  e.g. "path:23", "path:~45" (old side), "path:23-30" (range)
local function locator(c)
  local prefix = (c.side == "old") and "~" or ""
  if c.line == 0 then
    return c.file
  end
  if c.line_end and c.line_end ~= c.line then
    return string.format("%s:%s%d-%d", c.file, prefix, c.line, c.line_end)
  end
  return string.format("%s:%s%d", c.file, prefix, c.line)
end

---@param session table
---@return string
function M.generate_markdown(session)
  local all = store.get_all()
  local out = {}
  table.insert(out, string.format("# Review of PR #%d — %s", session.number, session.meta.title or ""))
  table.insert(out, "")
  table.insert(out, "I reviewed this PR and have the following comments. Please address them.")
  table.insert(out, "")
  table.insert(out, "Comments use semantic labels (escalating expectation): "
    .. "Remark (no action), Hint (consider for the future), Question (expects an answer), "
    .. "Suggestion (consider; your call), Important (expects a change), "
    .. "Crucial (must be fixed before merge). A `~` before a line number refers to the old side.")
  table.insert(out, "")
  local types = require("prtour.config").get().comment_types
  for i, c in ipairs(all) do
    local name = (types[c.type] and types[c.type].name) or c.type
    local body = c.text:gsub("\n", "\n   ")
    table.insert(out, string.format("%d. **%s** `%s` — %s", i, name .. ":", locator(c), body))
  end
  return table.concat(out, "\n")
end

---@param session table
function M.to_clipboard(session)
  local n = store.count()
  if n == 0 then
    vim.notify("No comments to export", vim.log.levels.WARN, { title = "prtour" })
    return
  end
  local md = M.generate_markdown(session)
  vim.fn.setreg("+", md)
  vim.fn.setreg("*", md)
  vim.notify(string.format("Exported %d comment(s) to clipboard", n), vim.log.levels.INFO, { title = "prtour" })
end

-- Find the hunk in `session.files` containing (path, file_line on `side`).
local function find_hunk(session, path, side, file_line)
  local file = session.file_index[path]
  if not file then
    return nil, nil
  end
  for _, hunk in ipairs(file.hunks) do
    for _, l in ipairs(hunk.lines) do
      local ln = (side == "old") and l.old_lineno or l.new_lineno
      if ln == file_line then
        return file, hunk
      end
    end
  end
  return file, nil
end

-- Yank a `path:line` + surrounding hunk block to clipboard for pasting to Claude.
---@param session table
function M.yank_context(session)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local a = session.anchors and session.anchors[cur]
  if not a then
    vim.notify("Place the cursor on a diff line", vim.log.levels.WARN, { title = "prtour" })
    return
  end
  local file, hunk = find_hunk(session, a.path, a.side, a.file_line)
  local lines = {}
  table.insert(lines, string.format("In PR #%d, `%s:%d`:", session.number, a.path, a.file_line))
  table.insert(lines, "")
  table.insert(lines, "```diff")
  if hunk then
    table.insert(lines, string.format("@@ -%d +%d @@ %s", hunk.old_start, hunk.new_start, hunk.heading))
    for _, l in ipairs(hunk.lines) do
      table.insert(lines, l.kind .. l.text)
    end
  elseif file then
    table.insert(lines, "(line not part of a changed hunk)")
  end
  table.insert(lines, "```")
  table.insert(lines, "")
  table.insert(lines, "My question: ")
  local block = table.concat(lines, "\n")
  vim.fn.setreg("+", block)
  vim.fn.setreg("*", block)
  vim.notify("Yanked context to clipboard", vim.log.levels.INFO, { title = "prtour" })
end

return M
