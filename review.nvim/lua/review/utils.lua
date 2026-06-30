local M = {}

---Normalize a file path for consistent storage/lookup
---@param path string
---@return string
function M.normalize_path(path)
  if not path then
    return path
  end
  path = path:gsub("^%./", "")
  path = path:gsub("/+$", "")
  return path
end

return M
