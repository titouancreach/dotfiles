-- Orchestrates opening a PR as a tour: fetch -> parse -> render -> wire up.
local M = {}

local gh = require("prtour.gh")
local diff = require("prtour.diff")
local ai = require("prtour.ai")
local render = require("prtour.render")
local comments = require("prtour.comments")
local store = require("prtour.store")
local storage = require("prtour.storage")
local keymaps = require("prtour.keymaps")

---@type table<integer, table>  bufnr -> session
M.sessions = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.ERROR, { title = "prtour" })
end

---@param opts { mode: string, number?: integer, meta: table, repo: string, files: table, name: string, root?: string }
local function make_session(opts)
  local file_index = {}
  for _, f in ipairs(opts.files) do
    file_index[f.path] = f
  end

  -- Scratch buffer in a new tab.
  vim.cmd("tabnew")
  local win = vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, bufnr)
  pcall(vim.api.nvim_buf_set_name, bufnr, opts.name)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "hide"
  -- Setting filetype triggers ftplugin/prtour.lua, which pins manual folding
  -- and the display options for this window.
  vim.bo[bufnr].filetype = "prtour"

  -- Head repo (the PR's source repo — may be a fork) for fetching file blobs.
  local head_repo = opts.repo
  local meta = opts.meta
  if type(meta.headRepositoryOwner) == "table" and type(meta.headRepository) == "table" then
    head_repo = meta.headRepositoryOwner.login .. "/" .. meta.headRepository.name
  end

  return {
    mode = opts.mode,
    number = opts.number,
    meta = meta,
    repo = opts.repo,
    head_repo = head_repo,
    root = opts.root,
    files = opts.files,
    file_index = file_index,
    bufnr = bufnr,
    win = win,
    tour = ai.fallback_tour(opts.files),
  }
end

local function draw(session)
  render.render(session)
  comments.render(session)
end

-- Shared: generate the AI tour for an already-built session and render it.
---@param session table
---@param diff_text string
---@param cache_oid string|nil
---@param force? boolean
local function generate_and_render(session, diff_text, cache_oid, force)
  local cached = (not force) and cache_oid and ai.load_cached(cache_oid)
  if cached then
    session.tour = cached
    draw(session)
    if session.mode == "pr" then
      M.load_github_comments(session)
    end
    notify("Tour ready (cached) ✓", vim.log.levels.INFO)
    return
  end

  render.render_loading(session)
  local tour_spin = require("prtour.spinner").buffer(session.bufnr, "Generating tour with Claude…")
  ai.generate_tour(session.meta, session.files, diff_text, function(tour, ai_used)
    tour_spin:stop()
    if not vim.api.nvim_buf_is_valid(session.bufnr) then
      return
    end
    session.tour = tour
    draw(session)
    if session.mode == "pr" then
      M.load_github_comments(session)
    end
    if ai_used and cache_oid then
      ai.save_cached(cache_oid, tour)
    end
    notify(ai_used and "Tour ready ✓" or "Tour ready (no AI — fallback ordering)", vim.log.levels.INFO)
  end)
end

-- Fetch existing GitHub review comments and re-render them onto the tour.
---@param session table
---@param announce? boolean  notify when done (for manual reloads)
function M.load_github_comments(session, announce)
  gh.list_review_comments(session.repo, session.number, function(list, err)
    if not list then
      if announce then
        notify("Could not load GitHub comments: " .. (err or ""))
      end
      return
    end
    -- JSON null decodes to vim.NIL (userdata, truthy in Lua) — coerce to nil.
    local function val(v)
      if v == nil or v == vim.NIL then
        return nil
      end
      return v
    end
    local mapped = {}
    for _, c in ipairs(list) do
      local path = val(c.path)
      local line = val(c.line) or val(c.original_line)
      if path and type(line) == "number" then
        table.insert(mapped, {
          path = path,
          side = (val(c.side) == "LEFT") and "old" or "new",
          line = line,
          body = val(c.body) or "",
          author = (val(c.user) and val(c.user.login)) or "?",
        })
      end
    end
    session.gh_comments = mapped
    if vim.api.nvim_buf_is_valid(session.bufnr) then
      comments.render(session)
    end
    if announce then
      notify(string.format("Loaded %d GitHub comment(s)", #mapped), vim.log.levels.INFO)
    end
  end)
end

-- Accept a bare PR number, a full github PR URL, or owner/repo#number.
---@param input string|integer
---@return { ref: string, repo: string|nil, number: integer }|nil
local function parse_input(input)
  input = vim.trim(tostring(input or ""))
  local owner, repo, num = input:match("^https?://[^/]+/([^/]+)/([^/]+)/pull/(%d+)")
  if owner then
    return { ref = input, repo = owner .. "/" .. repo, number = tonumber(num) }
  end
  local o2, r2, n2 = input:match("^([%w._%-]+)/([%w._%-]+)[#/](%d+)$")
  if o2 then
    return { ref = o2 .. "/" .. r2 .. "#" .. n2, repo = o2 .. "/" .. r2, number = tonumber(n2) }
  end
  if input:match("^%d+$") then
    return { ref = input, repo = nil, number = tonumber(input) }
  end
  return nil
end

---@param input string|integer  PR number, github PR URL, or owner/repo#number
---@param force? boolean  bypass the cached tour (regenerate)
function M.open(input, force)
  local spec = parse_input(input)
  if not spec then
    notify("Usage: :PrTour <number | url | owner/repo#number>")
    return
  end
  local number, ref = spec.number, spec.ref

  local spinner = require("prtour.spinner")
  local load_spin = spinner.cmdline("Loading PR #" .. number .. "…")
  local function fail(msg)
    load_spin:stop()
    notify(msg)
  end

  local function proceed(repo)
    gh.pr_meta(ref, function(meta, merr)
      if not meta then
        fail("Could not load PR #" .. number .. ": " .. (merr or ""))
        return
      end
      gh.pr_diff(ref, function(diff_text, derr)
        if not diff_text then
          fail("Could not load diff for PR #" .. number .. ": " .. (derr or ""))
          return
        end
        load_spin:stop()
        local files = diff.parse(diff_text)

        -- Scope + load persisted comments for this PR.
        storage.set_pr(repo, number)
        store.load()

        local session = make_session({
          mode = "pr",
          number = number,
          meta = meta,
          repo = repo,
          files = files,
          name = string.format("prtour://PR-%d", number),
        })
        session.ref = ref
        M.sessions[session.bufnr] = session
        M.current = session
        keymaps.setup(session)

        generate_and_render(session, diff_text, meta.headRefOid, force)
      end)
    end)
  end

  if spec.repo then
    proceed(spec.repo)
  else
    -- Bare number: resolve the current repo.
    gh.repo(function(repo, rerr)
      if not repo then
        fail("Not in a GitHub repo? " .. (rerr or ""))
        return
      end
      proceed(repo)
    end)
  end
end

M._parse_input = parse_input

-- Open a tour of the local working-tree changes (uncommitted, vs HEAD).
---@param force? boolean
function M.open_local(force)
  local git = require("prtour.git")
  local load_spin = require("prtour.spinner").cmdline("Loading local changes…")
  local function fail(msg)
    load_spin:stop()
    notify(msg)
  end

  git.root(function(root, rerr)
    if not root then
      fail("Not in a git repo? " .. (rerr or ""))
      return
    end
    git.branch(function(branch)
      git.diff(function(diff_text, derr)
        if not diff_text then
          fail("git diff failed: " .. (derr or ""))
          return
        end
        load_spin:stop()
        if vim.trim(diff_text) == "" then
          notify("No uncommitted changes", vim.log.levels.INFO)
          return
        end
        local files = diff.parse(diff_text)
        branch = branch or "working-tree"

        storage.set_scope(root, "local-" .. branch:gsub("[^%w%-_]", "_"))
        store.load()

        local meta = {
          title = "Local changes · " .. branch,
          additions = 0,
          deletions = 0,
          changedFiles = #files,
          url = root,
        }
        for _, f in ipairs(files) do
          meta.additions = meta.additions + f.additions
          meta.deletions = meta.deletions + f.deletions
        end

        local session = make_session({
          mode = "local",
          meta = meta,
          repo = root,
          root = root,
          files = files,
          name = "prtour://local",
        })
        session.ref = "local"
        M.sessions[session.bufnr] = session
        M.current = session
        keymaps.setup(session)

        -- Cache keyed by the diff content (working tree changes often).
        local oid = "local-" .. vim.fn.sha256(diff_text):sub(1, 16)
        generate_and_render(session, diff_text, oid, force)
      end)
    end)
  end)
end

local EXPAND_STEP = 20

-- Expand hidden diff context at the cursor, if it's on an expander line.
-- Returns true if it handled the line (so the caller can fall back to folds).
---@param session table
---@return boolean
function M.expand_context(session)
  local bl = vim.api.nvim_win_get_cursor(0)[1]
  local e = session.expanders and session.expanders[bl]
  if not e then
    return false
  end

  local function do_expand()
    session.expand = session.expand or {}
    session.expand[e.path] = session.expand[e.path] or {}
    session.expand[e.path][e.hunk_idx] = (session.expand[e.path][e.hunk_idx] or 0) + EXPAND_STEP
    draw(session)
  end

  if session.file_content and session.file_content[e.path] then
    do_expand()
    return true
  end

  -- Local mode: read the working-tree file straight from disk.
  if session.mode == "local" then
    local abs = (session.root or vim.fn.getcwd()) .. "/" .. e.path
    local ok, lines = pcall(vim.fn.readfile, abs)
    if not ok then
      notify("Could not read " .. e.path)
      return true
    end
    session.file_content = session.file_content or {}
    session.file_content[e.path] = lines
    do_expand()
    return true
  end

  local spin = require("prtour.spinner").cmdline("Loading file context…")
  gh.file_content(session.head_repo or session.repo, session.meta.headRefOid, e.path, function(content, err)
    spin:stop()
    if not content then
      notify("Could not load context for " .. e.path .. ": " .. (err or ""))
      return
    end
    session.file_content = session.file_content or {}
    session.file_content[e.path] = vim.split(content, "\n", { plain = true })
    do_expand()
  end)
  return true
end

-- Delete all local (unsent) comments for this tour, after confirmation.
---@param session table
function M.clear_comments(session)
  session = session or M.current
  if not session then
    return
  end
  local n = store.count()
  if n == 0 then
    notify("No comments to clear", vim.log.levels.INFO)
    return
  end
  if vim.fn.confirm(string.format("Delete all %d comment(s)?", n), "&Yes\n&No", 2) ~= 1 then
    return
  end
  store.clear()
  comments.render(session)
  notify(string.format("Cleared %d comment(s)", n), vim.log.levels.INFO)
end

---@param session table
function M.close(session)
  session = session or M.current
  if not session then
    return
  end
  require("prtour.export").to_clipboard(session)
  M.sessions[session.bufnr] = nil
  if vim.api.nvim_buf_is_valid(session.bufnr) then
    vim.api.nvim_buf_delete(session.bufnr, { force = true })
  end
  if M.current == session then
    M.current = nil
  end
  storage.clear_scope()
end

return M
