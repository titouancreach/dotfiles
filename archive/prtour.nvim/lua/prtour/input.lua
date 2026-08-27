-- A real editable buffer for composing a comment (full vim motions / modes).
--   :wq / :x / ZZ  -> save   ·   :q / ZQ -> discard   ·   <Tab> -> change type
local M = {}

local function config()
  return require("prtour.config").get()
end
local function types()
  return config().comment_type_order
end
local function type_meta()
  return config().comment_types
end

---@param initial_type? string
---@param initial_text? string
---@param callback fun(comment_type: string|nil, text: string|nil)
function M.open(initial_type, initial_text, callback)
  local meta = type_meta()
  local TYPES = types()
  local type_idx = 1
  for i, t in ipairs(TYPES) do
    if t == initial_type then
      type_idx = i
    end
  end

  local prev_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "acwrite" -- so :w fires BufWriteCmd (no real file)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  pcall(vim.api.nvim_buf_set_name, buf, "prtour://comment")
  if initial_text and initial_text ~= "" then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(initial_text, "\n", { plain = true }))
  end
  vim.bo[buf].modified = false

  vim.cmd("botright 10split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].winfixheight = true
  vim.wo[win].spell = true

  local done = false

  local function set_winbar()
    local info = meta[TYPES[type_idx]] or { icon = "", name = TYPES[type_idx] }
    vim.wo[win].winbar = string.format(
      "  %s %s   │   <Tab> change type · :wq save · :q discard",
      info.icon or "", info.name or TYPES[type_idx]
    )
  end
  set_winbar()

  -- Finish the editor exactly once: commit `text` (nil/empty => discard).
  local function finish(text)
    if done then
      return
    end
    done = true
    local ctype = TYPES[type_idx]
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_close, win, true)
      end
      if text and text ~= "" then
        callback(ctype, text)
      else
        callback(nil, nil)
      end
      if vim.api.nvim_win_is_valid(prev_win) then
        pcall(vim.api.nvim_set_current_win, prev_win)
      end
    end)
  end

  local grp = vim.api.nvim_create_augroup("prtour_input_" .. buf, { clear = true })

  -- :w / :wq / :x / ZZ  -> save.
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = grp,
    buffer = buf,
    callback = function()
      local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
      vim.bo[buf].modified = false
      finish(text)
    end,
  })

  -- Keep the buffer "unmodified" so a bare :q discards cleanly (no E37 nag).
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = grp,
    buffer = buf,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.bo[buf].modified = false
      end
    end,
  })

  -- Window closed without a write (:q / ZQ / <C-w>c) -> discard.
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = grp,
    buffer = buf,
    callback = function()
      finish(nil)
    end,
  })

  -- <Tab> cycles the comment type.
  vim.keymap.set("n", "<Tab>", function()
    type_idx = type_idx % #TYPES + 1
    set_winbar()
  end, { buffer = buf, nowait = true, desc = "prtour: cycle comment type" })

  vim.cmd("startinsert")
end

return M
