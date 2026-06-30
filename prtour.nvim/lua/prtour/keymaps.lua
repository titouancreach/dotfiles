-- Buffer-local keymaps for the tour buffer.
local M = {}

-- Label/icon/group metadata per action (drives which-key + the g? cheatsheet).
local META = {
  add_comment      = { label = "Add comment", icon = "💬", group = "Comments" },
  edit_comment     = { label = "Edit comment", icon = "✏️", group = "Comments" },
  delete_comment   = { label = "Delete comment", icon = "🗑️", group = "Comments" },
  next_comment     = { label = "Next comment", icon = "⬇️", group = "Navigation" },
  prev_comment     = { label = "Prev comment", icon = "⬆️", group = "Navigation" },
  next_section     = { label = "Next section", icon = "▶️", group = "Navigation" },
  prev_section     = { label = "Prev section", icon = "◀️", group = "Navigation" },
  open_fold        = { label = "Toggle fold", icon = "📂", group = "Navigation" },
  yank_context     = { label = "Yank context for Claude", icon = "📋", group = "Actions" },
  open_codediff    = { label = "Open file in codediff", icon = "🔍", group = "Actions" },
  reload_comments  = { label = "Reload GitHub comments", icon = "🔃", group = "Actions" },
  export_clipboard = { label = "Export comments", icon = "📑", group = "Actions" },
  refresh          = { label = "Refresh tour", icon = "🔄", group = "Actions" },
  close            = { label = "Close (export)", icon = "❌", group = "Actions" },
  approve          = { label = "Approve PR", icon = "✅", group = "GitHub" },
  request_changes  = { label = "Request changes", icon = "🔴", group = "GitHub" },
  push             = { label = "Push (comment review)", icon = "📤", group = "GitHub" },
  help             = { label = "Show keymaps", icon = "❓", group = "Other" },
}

local function map(bufnr, lhs, fn, action)
  if not lhs then
    return
  end
  local label = (META[action] and META[action].label) or action
  vim.keymap.set("n", lhs, fn, { buffer = bufnr, nowait = true, silent = true, desc = "PR Tour: " .. label })
end

-- Register the buffer-local maps with which-key (labels + icons) if available.
local function register_which_key(bufnr, km)
  local ok, wk = pcall(require, "which-key")
  if not ok or type(wk.add) ~= "function" then
    return
  end
  local spec = {}
  for action, lhs in pairs(km) do
    local meta = META[action]
    if lhs and meta then
      table.insert(spec, { lhs, desc = meta.label, icon = meta.icon, buffer = bufnr })
    end
  end
  pcall(wk.add, spec)
end

-- Move to the next/prev section header (recorded during render).
local function goto_section(session, dir)
  local headers = session.section_lines or {}
  if #headers == 0 then
    return
  end
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local target
  if dir == 1 then
    for _, l in ipairs(headers) do
      if l > cur then
        target = l
        break
      end
    end
    target = target or headers[1]
  else
    for i = #headers, 1, -1 do
      if headers[i] < cur then
        target = headers[i]
        break
      end
    end
    target = target or headers[#headers]
  end
  vim.api.nvim_win_set_cursor(0, { target, 0 })
end

---@param session table
function M.setup(session)
  local cfg = require("prtour.config").get()
  local km = cfg.keymaps
  local bufnr = session.bufnr
  local comments = require("prtour.comments")
  local export = require("prtour.export")
  local review = require("prtour.review")
  local tour = require("prtour.tour")

  map(bufnr, km.add_comment, function()
    comments.add(session)
  end, "add_comment")

  -- Visual-mode range comment.
  if km.add_comment then
    vim.keymap.set("x", km.add_comment, function()
      local s = vim.fn.line("v")
      local e = vim.fn.line(".")
      if s > e then
        s, e = e, s
      end
      vim.api.nvim_input("<Esc>")
      vim.schedule(function()
        comments.add(session, { start = s, stop = e })
      end)
    end, { buffer = bufnr, silent = true, desc = "PR Tour: comment range" })
  end

  map(bufnr, km.edit_comment, function()
    comments.edit(session)
  end, "edit_comment")
  map(bufnr, km.delete_comment, function()
    comments.delete(session)
  end, "delete_comment")
  map(bufnr, km.next_comment, function()
    comments.goto_comment(session, 1)
  end, "next_comment")
  map(bufnr, km.prev_comment, function()
    comments.goto_comment(session, -1)
  end, "prev_comment")
  map(bufnr, km.next_section, function()
    goto_section(session, 1)
  end, "next_section")
  map(bufnr, km.prev_section, function()
    goto_section(session, -1)
  end, "prev_section")
  map(bufnr, km.yank_context, function()
    export.yank_context(session)
  end, "yank_context")
  map(bufnr, km.open_codediff, function()
    require("prtour.codediff").open_under_cursor(session)
  end, "open_codediff")
  map(bufnr, km.reload_comments, function()
    tour.load_github_comments(session, true)
  end, "reload_comments")
  map(bufnr, km.export_clipboard, function()
    export.to_clipboard(session)
  end, "export_clipboard")
  map(bufnr, km.approve, function()
    review.submit(session, "APPROVE")
  end, "approve")
  map(bufnr, km.request_changes, function()
    review.submit(session, "REQUEST_CHANGES")
  end, "request_changes")
  map(bufnr, km.push, function()
    review.submit(session, "COMMENT")
  end, "push")
  map(bufnr, km.refresh, function()
    if session.mode == "local" then
      tour.open_local(true)
    else
      tour.open(session.ref or session.number, true)
    end
  end, "refresh")
  map(bufnr, km.close, function()
    tour.close(session)
  end, "close")
  map(bufnr, km.help, function()
    M.help()
  end, "help")

  -- Folds: open_fold uses <CR>; toggle_fold uses default za but we map it explicitly
  -- so it works even where za is shadowed.
  if km.open_fold then
    map(bufnr, km.open_fold, function()
      -- On an "expand" line, reveal hidden context; otherwise toggle the fold.
      if not tour.expand_context(session) then
        pcall(vim.cmd, "normal! za")
      end
    end, "open_fold")
  end

  register_which_key(bufnr, km)
end

local GROUP_ORDER = { "Comments", "Navigation", "Actions", "GitHub", "Other" }

-- A focused floating cheatsheet of all prtour keys, grouped.
function M.help()
  local km = require("prtour.config").get().keymaps
  local by_group = {}
  for action, lhs in pairs(km) do
    local meta = META[action]
    if lhs and meta then
      by_group[meta.group] = by_group[meta.group] or {}
      table.insert(by_group[meta.group], { lhs = lhs, label = meta.label, icon = meta.icon })
    end
  end

  local lines = { "  🧭  PR Tour — keybindings", "" }
  for _, g in ipairs(GROUP_ORDER) do
    local items = by_group[g]
    if items then
      table.sort(items, function(a, b)
        return a.label < b.label
      end)
      table.insert(lines, "  " .. g)
      for _, it in ipairs(items) do
        table.insert(lines, string.format("    %-10s %s %s", it.lhs, it.icon, it.label))
      end
      table.insert(lines, "")
    end
  end
  table.insert(lines, "  (q / <Esc> to close)")

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = width + 2
  local height = #lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = "rounded",
    title = " prtour ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = false
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
  end
end

return M
