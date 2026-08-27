-- Per-PR disk persistence for prtour comments.
local M = {}

local data_dir = vim.fn.stdpath("data") .. "/prtour"

---@type {repo: string, key: string}|nil
local scope = nil

---@param str string
---@return string
local function hash(str)
  local h = 0
  for i = 1, #str do
    h = ((h * 31) + string.byte(str, i)) % 2147483647
  end
  return string.format("%x", h)
end

-- Scope comments to an arbitrary key (e.g. "pr482" or "local-main").
---@param repo string
---@param key string
function M.set_scope(repo, key)
  scope = { repo = repo, key = key }
end

---@param repo string  e.g. "owner/name"
---@param number integer
function M.set_pr(repo, number)
  M.set_scope(repo, "pr" .. number)
end

function M.clear_scope()
  scope = nil
end

---@return string|nil
function M.get_storage_path()
  if not scope then
    return nil
  end
  pcall(vim.fn.mkdir, data_dir, "p")
  return string.format("%s/%s-%s.json", data_dir, hash(scope.repo), scope.key)
end

local EXPIRY_SECONDS = 30 * 24 * 60 * 60
local cleanup_done = false

function M.cleanup_expired()
  if cleanup_done then
    return
  end
  cleanup_done = true
  vim.defer_fn(function()
    local files = vim.fn.glob(data_dir .. "/*.json", false, true)
    local now = os.time()
    for _, filepath in ipairs(files) do
      local mtime = vim.fn.getftime(filepath)
      if mtime > 0 and (now - mtime) > EXPIRY_SECONDS then
        os.remove(filepath)
      end
    end
  end, 0)
end

---@param comments table
function M.save(comments)
  local path = M.get_storage_path()
  if not path then
    return
  end
  local file = io.open(path, "w")
  if file then
    file:write(vim.json.encode(comments))
    file:close()
  end
end

---@return table
function M.load()
  M.cleanup_expired()
  local path = M.get_storage_path()
  if not path then
    return {}
  end
  local file = io.open(path, "r")
  if not file then
    return {}
  end
  local content = file:read("*a")
  file:close()
  if content and content ~= "" then
    local ok, data = pcall(vim.json.decode, content)
    if ok and data then
      return data
    end
  end
  return {}
end

function M.clear()
  local path = M.get_storage_path()
  if path then
    os.remove(path)
  end
end

return M
