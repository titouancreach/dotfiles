-- Minimal async git helpers for local (working-tree) reviews.
local M = {}

local function run(cmd, cb)
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        cb(nil, (res.stderr ~= "" and res.stderr or res.stdout) or ("exit " .. res.code))
      else
        cb(res.stdout, nil)
      end
    end)
  end)
end

-- All uncommitted changes to tracked files (staged + unstaged) vs HEAD.
---@param cb fun(diff: string|nil, err: string|nil)
function M.diff(cb)
  run({ "git", "diff", "HEAD" }, cb)
end

---@param cb fun(branch: string|nil, err: string|nil)
function M.branch(cb)
  run({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, function(o, e)
    cb(o and vim.trim(o), e)
  end)
end

---@param cb fun(root: string|nil, err: string|nil)
function M.root(cb)
  run({ "git", "rev-parse", "--show-toplevel" }, function(o, e)
    cb(o and vim.trim(o), e)
  end)
end

return M
