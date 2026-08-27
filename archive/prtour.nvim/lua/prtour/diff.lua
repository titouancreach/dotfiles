-- Parse a unified diff (as produced by `gh pr diff <n>`) into a structured model.
local M = {}

---@class PrDiffLine
---@field kind " "|"+"|"-"  context / added / removed
---@field text string       line content (without the leading +/-/space)
---@field old_lineno? number line number on the old side (nil for added lines)
---@field new_lineno? number line number on the new side (nil for removed lines)

---@class PrDiffHunk
---@field old_start number
---@field new_start number
---@field heading string     text after the second @@ (function context), may be ""
---@field lines PrDiffLine[]

---@class PrDiffFile
---@field path string        new path (or old path for deletions)
---@field old_path string
---@field status "modified"|"added"|"deleted"|"renamed"
---@field binary boolean
---@field additions number
---@field deletions number
---@field hunks PrDiffHunk[]

---@param diff_text string
---@return PrDiffFile[]
function M.parse(diff_text)
  local files = {}
  local cur_file = nil
  local cur_hunk = nil
  local old_ln, new_ln = 0, 0

  local function strip_prefix(p)
    -- a/foo/bar.txt -> foo/bar.txt ; keep /dev/null as-is
    if p == "/dev/null" then
      return p
    end
    return (p:gsub("^[ab]/", ""))
  end

  for _, raw in ipairs(vim.split(diff_text or "", "\n", { plain = true })) do
    if raw:match("^diff %-%-git ") then
      -- Start a new file.
      cur_file = {
        path = "",
        old_path = "",
        status = "modified",
        binary = false,
        additions = 0,
        deletions = 0,
        hunks = {},
      }
      cur_hunk = nil
      table.insert(files, cur_file)
      -- Pull paths from the `diff --git a/x b/y` line as a fallback.
      local a, b = raw:match("^diff %-%-git a/(.-) b/(.+)$")
      if a then
        cur_file.old_path = a
        cur_file.path = b
      end
    elseif cur_file == nil then
      -- ignore any preamble before the first file
    elseif raw:match("^new file mode") then
      cur_file.status = "added"
    elseif raw:match("^deleted file mode") then
      cur_file.status = "deleted"
    elseif raw:match("^rename from ") then
      cur_file.status = "renamed"
      cur_file.old_path = raw:match("^rename from (.+)$") or cur_file.old_path
    elseif raw:match("^rename to ") then
      cur_file.path = raw:match("^rename to (.+)$") or cur_file.path
    elseif raw:match("^Binary files ") or raw:match("^GIT binary patch") then
      cur_file.binary = true
    elseif raw:match("^%-%-%- ") then
      local p = strip_prefix(raw:sub(5))
      cur_file.old_path = p
    elseif raw:match("^%+%+%+ ") then
      local p = strip_prefix(raw:sub(5))
      if p ~= "/dev/null" then
        cur_file.path = p
      end
    elseif raw:match("^@@ ") then
      -- @@ -old_start,old_count +new_start,new_count @@ heading
      local os_, oc_, ns_, nc_, heading =
        raw:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@ ?(.*)$")
      if os_ then
        old_ln = tonumber(os_)
        new_ln = tonumber(ns_)
        cur_hunk = {
          old_start = old_ln,
          new_start = new_ln,
          heading = heading or "",
          lines = {},
        }
        table.insert(cur_file.hunks, cur_hunk)
      end
    elseif cur_hunk then
      local first = raw:sub(1, 1)
      if first == "+" then
        table.insert(cur_hunk.lines, { kind = "+", text = raw:sub(2), new_lineno = new_ln })
        new_ln = new_ln + 1
        cur_file.additions = cur_file.additions + 1
      elseif first == "-" then
        table.insert(cur_hunk.lines, { kind = "-", text = raw:sub(2), old_lineno = old_ln })
        old_ln = old_ln + 1
        cur_file.deletions = cur_file.deletions + 1
      elseif first == " " or raw == "" then
        table.insert(cur_hunk.lines, {
          kind = " ",
          text = raw:sub(2),
          old_lineno = old_ln,
          new_lineno = new_ln,
        })
        old_ln = old_ln + 1
        new_ln = new_ln + 1
      elseif raw:sub(1, 1) == "\\" then
        -- "\ No newline at end of file" — ignore
      end
    end
  end

  -- Normalize paths: prefer new path; for deletions use old path.
  for _, f in ipairs(files) do
    if f.path == "" or f.path == "/dev/null" then
      f.path = f.old_path
    end
    if f.old_path == "" then
      f.old_path = f.path
    end
  end

  return files
end

return M
