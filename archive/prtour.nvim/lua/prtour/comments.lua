-- Comment workflow + box rendering, driven by the anchor map.
local M = {}

local store = require("prtour.store")

M.ns = vim.api.nvim_create_namespace("prtour_comments")

local function comment_types()
  return require("prtour.config").get().comment_types
end

local function open_popup(initial_type, initial_text, cb)
  local ui = require("prtour.config").get().comment_ui
  if ui ~= "popup" then
    require("prtour.input").open(initial_type, initial_text, cb)
    return
  end
  -- Opt-in: review.nvim's nui popup (<C-s> submit).
  local ok, popup = pcall(require, "review.popup")
  if ok then
    popup.open(initial_type, initial_text, cb)
    return
  end
  require("prtour.input").open(initial_type, initial_text, cb)
end

-- anchor at a buffer line (1-based)
local function anchor_at(session, bufline)
  return session.anchors and session.anchors[bufline] or nil
end

-- Build path|side|line -> bufline index from anchors.
local function build_index(session)
  local idx = {}
  for bufline, a in pairs(session.anchors or {}) do
    if a and a.file_line then
      idx[string.format("%s|%s|%d", a.path, a.side, a.file_line)] = bufline
    end
  end
  return idx
end

local MAX_BOX_WIDTH = 76

local function disp(s)
  return vim.fn.strdisplaywidth(s)
end

-- Break a single word that's wider than `w` into display-width-bounded pieces.
local function hard_break(word, w)
  local pieces, cur = {}, ""
  for _, ch in ipairs(vim.fn.split(word, "\\zs")) do
    if cur ~= "" and disp(cur .. ch) > w then
      table.insert(pieces, cur)
      cur = ch
    else
      cur = cur .. ch
    end
  end
  if cur ~= "" then
    table.insert(pieces, cur)
  end
  return pieces
end

-- Word-wrap one line to `w` display columns (hard-breaking over-long words).
local function wrap_line(s, w)
  local out, line = {}, ""
  for word in s:gmatch("%S+") do
    if disp(word) > w then
      if line ~= "" then
        table.insert(out, line)
        line = ""
      end
      local pieces = hard_break(word, w)
      for i = 1, #pieces - 1 do
        table.insert(out, pieces[i])
      end
      line = pieces[#pieces] or ""
    elseif line == "" then
      line = word
    elseif disp(line) + 1 + disp(word) <= w then
      line = line .. " " .. word
    else
      table.insert(out, line)
      line = word
    end
  end
  if line ~= "" then
    table.insert(out, line)
  end
  return out
end

-- Draw a boxed comment as virt_lines below `bufline`.
local function draw_box(bufnr, bufline, header, body_text, hl)
  local body = {}
  for _, raw in ipairs(vim.split(body_text, "\n", { plain = true })) do
    if raw == "" then
      table.insert(body, "")
    else
      vim.list_extend(body, wrap_line(raw, MAX_BOX_WIDTH))
    end
  end
  if #body == 0 then
    body = { "" }
  end

  local width = disp(header)
  for _, l in ipairs(body) do
    width = math.max(width, disp(l))
  end
  width = math.min(width, MAX_BOX_WIDTH)

  local function row(content, content_hl)
    local pad = width - vim.fn.strdisplaywidth(content)
    return { { "│ ", hl }, { content .. string.rep(" ", math.max(0, pad)), content_hl }, { " │", hl } }
  end
  local virt = { { { "╭" .. string.rep("─", width + 2) .. "╮", hl } } }
  table.insert(virt, row(header, hl))
  for _, l in ipairs(body) do
    table.insert(virt, row(l, "PrTourCommentText"))
  end
  table.insert(virt, { { "╰" .. string.rep("─", width + 2) .. "╯", hl } })

  vim.api.nvim_buf_set_extmark(bufnr, M.ns, bufline - 1, 0, {
    virt_lines = virt,
    sign_text = "●",
    sign_hl_group = hl,
  })
end

---@param session table
function M.render(session)
  vim.api.nvim_buf_clear_namespace(session.bufnr, M.ns, 0, -1)
  local types = comment_types()
  local index = build_index(session)

  -- Existing GitHub review comments (read-only), drawn first.
  for _, gc in ipairs(session.gh_comments or {}) do
    local bufline = type(gc.line) == "number"
      and index[string.format("%s|%s|%d", gc.path, gc.side, gc.line)]
    if bufline then
      draw_box(session.bufnr, bufline, string.format("💬 @%s (GitHub)", gc.author or "?"), gc.body, "PrTourGitHub")
    end
  end

  -- Your local (unsent) comments.
  for _, c in ipairs(store.get_all()) do
    local bufline = type(c.line) == "number"
      and index[string.format("%s|%s|%d", c.file, c.side or "new", c.line)]
    if bufline then
      local info = types[c.type] or { icon = "•", name = c.type, hl = "Comment" }
      draw_box(session.bufnr, bufline, string.format("%s %s", info.icon, info.name or c.type), c.text, info.hl or "Comment")
    end
  end
end

-- Add a comment at the cursor (or visual range), opening the popup.
---@param session table
---@param range? { start: integer, stop: integer }  buffer line range (1-based)
function M.add(session, range)
  local cur = range and range.start or vim.api.nvim_win_get_cursor(0)[1]
  local a = anchor_at(session, cur)
  if not a then
    vim.notify("Place the cursor on a diff line to comment", vim.log.levels.WARN, { title = "prtour" })
    return
  end

  -- Determine end line for a visual range on the same side/file.
  local line_end = a.file_line
  if range and range.stop > range.start then
    for bl = range.stop, range.start, -1 do
      local b = anchor_at(session, bl)
      if b and b.path == a.path and b.side == a.side then
        line_end = b.file_line
        break
      end
    end
  end

  open_popup(nil, nil, function(ctype, text)
    if not ctype or not text then
      return
    end
    store.add(a.path, a.file_line, ctype, text, line_end, a.side)
    M.render(session)
    local where = (line_end and line_end ~= a.file_line)
      and string.format("%s:%d-%d", a.path, a.file_line, line_end)
      or string.format("%s:%d", a.path, a.file_line)
    vim.notify(string.format("Comment added on %s (%d total)", where, store.count()),
      vim.log.levels.INFO, { title = "prtour" })
  end)
end

---@param session table
function M.edit(session)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local a = anchor_at(session, cur)
  if not a then
    return
  end
  local c = store.get_at_line(a.path, a.file_line, a.side)
  if not c then
    vim.notify("No comment here", vim.log.levels.WARN, { title = "prtour" })
    return
  end
  open_popup(c.type, c.text, function(ctype, text)
    if not ctype or not text then
      return
    end
    store.update(c.id, text, ctype)
    M.render(session)
  end)
end

---@param session table
function M.delete(session)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local a = anchor_at(session, cur)
  if not a then
    return
  end
  local c = store.get_at_line(a.path, a.file_line, a.side)
  if not c then
    vim.notify("No comment here", vim.log.levels.WARN, { title = "prtour" })
    return
  end
  store.delete(c.id)
  M.render(session)
  vim.notify(string.format("Comment deleted (%d left)", store.count()), vim.log.levels.INFO, { title = "prtour" })
end

-- Jump to next/prev buffer line that has a comment.
---@param session table
---@param dir 1|-1
function M.goto_comment(session, dir)
  local index = build_index(session)
  local commented = {}
  for _, c in ipairs(store.get_all()) do
    local bl = index[string.format("%s|%s|%d", c.file, c.side or "new", c.line)]
    if bl then
      table.insert(commented, bl)
    end
  end
  if #commented == 0 then
    return
  end
  table.sort(commented)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local target
  if dir == 1 then
    for _, bl in ipairs(commented) do
      if bl > cur then
        target = bl
        break
      end
    end
    target = target or commented[1]
  else
    for i = #commented, 1, -1 do
      if commented[i] < cur then
        target = commented[i]
        break
      end
    end
    target = target or commented[#commented]
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
end

return M
