-- In-memory comment store (mirrors review.nvim's Comment model so the
-- export/popup primitives stay compatible) backed by prtour.storage.
local M = {}

local storage = require("prtour.storage")

---@class PrComment
---@field id string
---@field file string        repo-relative path
---@field line number        1-indexed line on `side`; 0 = file-level
---@field line_end? number
---@field side "old"|"new"
---@field type "note"|"suggestion"|"issue"|"praise"
---@field text string
---@field created_at number

---@type table<string, PrComment[]>
M.comments = {}

local id_counter = 0
local loaded = false

local function generate_id()
  id_counter = id_counter + 1
  return string.format("comment_%d_%d", os.time(), id_counter)
end

local function persist()
  storage.save(M.comments)
end

function M.reset()
  M.comments = {}
  id_counter = 0
  loaded = false
end

function M.load()
  M.reset()
  M.comments = storage.load()
  for _, list in pairs(M.comments) do
    for _, c in ipairs(list) do
      local num = tonumber(tostring(c.id):match("comment_%d+_(%d+)"))
      if num and num > id_counter then
        id_counter = num
      end
    end
  end
  loaded = true
end

---@return PrComment
function M.add(file, line, type, text, line_end, side)
  M.comments[file] = M.comments[file] or {}
  local comment = {
    id = generate_id(),
    file = file,
    line = line,
    line_end = (line_end and line_end ~= line) and line_end or nil,
    side = side or "new",
    type = type,
    text = text,
    created_at = os.time(),
  }
  table.insert(M.comments[file], comment)
  persist()
  return comment
end

---@return PrComment|nil
function M.get(id)
  for _, list in pairs(M.comments) do
    for _, c in ipairs(list) do
      if c.id == id then
        return c
      end
    end
  end
end

-- Find a comment covering `line` on `side` for `file`.
---@return PrComment|nil
function M.get_at_line(file, line, side)
  for _, c in ipairs(M.comments[file] or {}) do
    local c_end = c.line_end or c.line
    if line >= c.line and line <= c_end and (c.side or "new") == side then
      return c
    end
  end
end

function M.update(id, text, new_type)
  local c = M.get(id)
  if not c then
    return false
  end
  c.text = text
  if new_type then
    c.type = new_type
  end
  persist()
  return true
end

function M.delete(id)
  for file, list in pairs(M.comments) do
    for i, c in ipairs(list) do
      if c.id == id then
        table.remove(list, i)
        if #list == 0 then
          M.comments[file] = nil
        end
        persist()
        return true
      end
    end
  end
  return false
end

---@return PrComment[]
function M.get_all()
  local all = {}
  for _, list in pairs(M.comments) do
    for _, c in ipairs(list) do
      table.insert(all, c)
    end
  end
  table.sort(all, function(a, b)
    if a.file ~= b.file then
      return a.file < b.file
    end
    return a.line < b.line
  end)
  return all
end

function M.count()
  local n = 0
  for _, list in pairs(M.comments) do
    n = n + #list
  end
  return n
end

function M.clear()
  M.reset()
  storage.clear()
end

return M
