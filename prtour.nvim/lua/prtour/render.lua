-- Build the tour buffer: real lines + the anchor map + highlights + folds.
local M = {}

M.ns = vim.api.nvim_create_namespace("prtour_render")

local SIGNAL_LABEL = { high = "HIGH", med = "MED", low = "LOW" }
local SIGNAL_EMOJI = { high = "🔴", med = "🟡", low = "⚪" }

local function norm_signal(s)
  return (s == "high" or s == "low") and s or "med"
end

-- prtour-owned highlight groups (theme-friendly links). Call once from setup.
function M.setup_highlights()
  local links = {
    PrTourTitle = "Title",
    PrTourFile = "Directory",
    PrTourHigh = "DiagnosticError",
    PrTourMed = "DiagnosticWarn",
    PrTourLow = "Comment",
    PrTourMuted = "Comment",
    PrTourHunk = "Comment",
    -- Semantic comment labels (escalating).
    PrTourRemark = "Comment",
    PrTourHint = "DiagnosticHint",
    PrTourQuestion = "DiagnosticInfo",
    PrTourSuggestion = "DiagnosticOk",
    PrTourImportant = "DiagnosticWarn",
    PrTourCrucial = "DiagnosticError",
    PrTourCommentText = "NormalFloat",
    PrTourGitHub = "Identifier",
    PrTourExpand = "Folded",
    PrTourTicket = "Special",
  }
  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end
end

---@param text string
---@param width integer
---@return string[]
local function wrap(text, width)
  local out = {}
  for _, para in ipairs(vim.split(text or "", "\n", { plain = true })) do
    if para == "" then
      table.insert(out, "")
    else
      local line = ""
      for word in para:gmatch("%S+") do
        if line == "" then
          line = word
        elseif #line + 1 + #word <= width then
          line = line .. " " .. word
        else
          table.insert(out, line)
          line = word
        end
      end
      if line ~= "" then
        table.insert(out, line)
      end
    end
  end
  return out
end

-- Render a whole tour into `session.bufnr`. Populates session.anchors and
-- (if session.win is set) creates section folds. Returns nothing.
---@param session table
function M.render(session)
  local files = session.files
  local file_index = session.file_index
  local tour = session.tour
  local bufnr = session.bufnr

  local lines = {}       -- buffer text
  local kinds = {}       -- per-line render kind for highlighting
  local anchors = {}     -- bufline -> { path, side, file_line, kind } | false
  local folds = {}       -- { {start=, stop=} } 1-based inclusive, for sections
  local section_lines = {} -- buflines of section headers (for navigation)
  local code_lines = {}  -- { bufline=, col=, text=, ft= } for treesitter highlighting
  local expanders = {}   -- bufline -> { path, hunk_idx } for context expansion

  local function emit(text, kind, anchor)
    table.insert(lines, text)
    kinds[#lines] = kind or "text"
    anchors[#lines] = anchor or false
  end

  local function render_file(file)
    if not file then
      return
    end
    local ft = vim.filetype.match({ filename = file.path })
    emit(string.format("📄 %s   +%d -%d", file.path, file.additions, file.deletions), "file")
    if file.binary then
      emit("    (binary file — not shown)", "muted")
      emit("")
      return
    end
    if #file.hunks == 0 then
      emit(string.format("    (%s, no textual changes)", file.status), "muted")
      emit("")
      return
    end
    local content = session.file_content and session.file_content[file.path]
    local expand = (session.expand and session.expand[file.path]) or {}

    local function emit_context_line(ln)
      local text = content and content[ln] or ""
      local prefix = string.format("%5s %s ", ln, " ")
      emit(prefix .. text, "diff_ctx", { path = file.path, side = "new", file_line = ln, kind = " " })
      if ft and text ~= "" then
        table.insert(code_lines, { bufline = #lines, col = #prefix, text = text, ft = ft })
      end
    end

    local prev_new_end = 0
    for i, hunk in ipairs(file.hunks) do
      -- Hidden lines above this hunk (between previous hunk and this one's
      -- leading context), on the new side.
      local gap_start = prev_new_end + 1
      local gap_end = hunk.new_start - 1
      local gap_size = math.max(0, gap_end - gap_start + 1)
      if gap_size > 0 then
        local revealed = math.min(expand[i] or 0, gap_size)
        local remaining = gap_size - revealed
        if remaining > 0 then
          local head = hunk.heading ~= "" and ("  ·  " .. hunk.heading) or ""
          emit(string.format("  ⊿ %d hidden line%s%s   <CR> to expand",
            remaining, remaining == 1 and "" or "s", head), "expand")
          expanders[#lines] = { path = file.path, hunk_idx = i }
        end
        for ln = hunk.new_start - revealed, hunk.new_start - 1 do
          emit_context_line(ln)
        end
      end

      for _, l in ipairs(hunk.lines) do
        local lineno, side, file_line, kind_name
        if l.kind == "+" then
          lineno, side, file_line, kind_name = l.new_lineno, "new", l.new_lineno, "diff_add"
        elseif l.kind == "-" then
          lineno, side, file_line, kind_name = l.old_lineno, "old", l.old_lineno, "diff_del"
        else
          lineno, side, file_line, kind_name = l.new_lineno, "new", l.new_lineno, "diff_ctx"
        end
        local prefix = string.format("%5s %s ", lineno or "", l.kind)
        emit(prefix .. l.text, kind_name, { path = file.path, side = side, file_line = file_line, kind = l.kind })
        if ft and l.text ~= "" then
          table.insert(code_lines, { bufline = #lines, col = #prefix, text = l.text, ft = ft })
        end
        if l.new_lineno then
          prev_new_end = l.new_lineno
        end
      end
    end
    emit("")
  end

  local function render_section(idx, title, signal, description, paths)
    local start = #lines + 1
    local sig = norm_signal(signal)
    local circle = SIGNAL_EMOJI[sig]
    emit(string.format("%s  %d. %s   ·  %s", circle, idx, title, SIGNAL_LABEL[sig]), "h2_" .. sig)
    table.insert(section_lines, start)
    if description and description ~= "" then
      for _, l in ipairs(wrap(description, 78)) do
        emit(l == "" and "" or ("   " .. l), "desc")
      end
    end
    emit("")
    for _, path in ipairs(paths) do
      render_file(file_index[path])
    end
    table.insert(folds, { start = start, stop = #lines })
  end

  -- Header.
  local title = (session.mode == "local")
    and string.format("🧭 %s", session.meta.title or "Local changes")
    or string.format("🧭 PR #%d — %s", session.number or 0, session.meta.title or "")
  emit(title, "h1")
  emit(string.format("  %s · +%d -%d · %d files",
    session.meta.url or "", session.meta.additions or 0, session.meta.deletions or 0,
    session.meta.changedFiles or 0), "muted")
  if tour.summary and tour.summary ~= "" then
    emit("")
    for _, l in ipairs(wrap(tour.summary, 78)) do
      emit(l == "" and "" or ("  " .. l), "summary")
    end
  end

  -- Linked Notion ticket (purpose), if any.
  local ticket = tour.ticket
  if ticket and (ticket.title or ticket.purpose) then
    emit("")
    emit(string.format("🎫 %s%s", ticket.title or "Ticket",
      ticket.url and ("   " .. ticket.url) or ""), "ticket")
    if ticket.purpose and ticket.purpose ~= "" then
      for _, l in ipairs(wrap(ticket.purpose, 78)) do
        emit(l == "" and "" or ("   " .. l), "desc")
      end
    end
  end
  emit("")

  -- Sections.
  local counter = 0
  for _, sec in ipairs(tour.sections or {}) do
    counter = counter + 1
    render_section(counter, sec.title or ("Section " .. counter), sec.signal, sec.description, sec.files or {})
  end

  -- Skim section (low signal), folded by default.
  local skim_fold = nil
  if tour.skim and #tour.skim > 0 then
    local start = #lines + 1
    emit("⚪  Skim (low signal)", "h2_low")
    table.insert(section_lines, start)
    emit("")
    for _, path in ipairs(tour.skim) do
      render_file(file_index[path])
    end
    skim_fold = { start = start, stop = #lines }
    table.insert(folds, skim_fold)
  end

  -- Commit text.
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

  session.anchors = anchors
  session.kinds = kinds
  session.section_lines = section_lines
  session.code_lines = code_lines
  session.expanders = expanders
  session.line_count = #lines

  -- Highlights.
  M.apply_highlights(bufnr, kinds)

  -- Folds (need a window).
  if session.win and vim.api.nvim_win_is_valid(session.win) then
    M.apply_folds(session.win, folds, skim_fold)
  end

  -- Treesitter syntax highlighting of the code (deferred so the tour paints
  -- instantly; the syntax colors fill in a tick later). Never fatal.
  vim.schedule(function()
    pcall(function()
      require("prtour.syntax").highlight(session)
    end)
  end)
end

-- A stable loading view shown until the full tour is ready (all-or-nothing).
---@param session table
function M.render_loading(session)
  local m = session.meta
  local header = (session.mode == "local")
    and string.format("🧭 %s", m.title or "Local changes")
    or string.format("🧭 PR #%d — %s", session.number or 0, m.title or "")
  local lines = {
    header,
    string.format("  %s · +%d -%d · %d files",
      m.url or "", m.additions or 0, m.deletions or 0, m.changedFiles or 0),
    "",
    "  ⏳ Generating tour with Claude — the diff will appear here once it's ready.",
  }
  vim.api.nvim_set_option_value("modifiable", true, { buf = session.bufnr })
  vim.api.nvim_buf_set_lines(session.bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = session.bufnr })
  M.apply_highlights(session.bufnr, { [1] = "h1", [2] = "muted", [4] = "h2_med" })
  session.anchors = {}
  session.section_lines = {}
end

local KIND_HL = {
  h1 = "PrTourTitle",
  h2_high = "PrTourHigh",
  h2_med = "PrTourMed",
  h2_low = "PrTourLow",
  file = "PrTourFile",
  hunk = "PrTourHunk",
  expand = "PrTourExpand",
  ticket = "PrTourTicket",
  desc = "Normal",
  summary = "Normal",
  muted = "PrTourMuted",
  diff_add = "DiffAdd",
  diff_del = "DiffDelete",
  diff_ctx = nil,
}

function M.apply_highlights(bufnr, kinds)
  vim.api.nvim_buf_clear_namespace(bufnr, M.ns, 0, -1)
  for lnum, kind in pairs(kinds) do
    local hl = KIND_HL[kind]
    if hl then
      vim.api.nvim_buf_set_extmark(bufnr, M.ns, lnum - 1, 0, {
        line_hl_group = hl,
      })
    end
  end
end

---@param win integer
---@param folds { start: integer, stop: integer }[]
---@param skim_fold { start: integer, stop: integer }|nil
function M.apply_folds(win, folds, skim_fold)
  local cfg = require("prtour.config").get()
  vim.api.nvim_win_call(win, function()
    vim.wo[win].foldmethod = "manual"
    vim.wo[win].foldenable = true
    vim.wo[win].foldlevel = 99
    vim.cmd("normal! zE") -- eliminate existing folds
    for _, f in ipairs(folds) do
      if f.stop > f.start then
        vim.cmd(string.format("%d,%dfold", f.start, f.stop))
        vim.cmd(string.format("%dfoldopen", f.start))
      end
    end
    if cfg.skim_folded and skim_fold and skim_fold.stop > skim_fold.start then
      vim.cmd(string.format("%dfoldclose", skim_fold.start))
    end
  end)
end

return M
