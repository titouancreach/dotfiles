-- Open the file under the cursor in codediff.nvim, diffing the PR's
-- base (merge-base) against its head — a side-by-side of just that file.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.ERROR, { title = "prtour" })
end

-- review.nvim auto-attaches its comment keymaps to ANY codediff session (it has
-- no opt-out). We wrap its two entry points so it skips tabs prtour opened, and
-- tag our codediff tab the moment it's created (well within review's 100ms defer).
local guarded = false

local function tab_is_prtour_owned()
  local ok, v = pcall(vim.api.nvim_tabpage_get_var, 0, "prtour_codediff")
  return ok and v == true
end

local function install_review_guard()
  if guarded then
    return
  end
  guarded = true
  local ok, review = pcall(require, "review")
  if not ok then
    return
  end
  for _, name in ipairs({ "_check_codediff_session", "_on_file_select" }) do
    local orig = review[name]
    if type(orig) == "function" then
      review[name] = function(...)
        if tab_is_prtour_owned() then
          return
        end
        return orig(...)
      end
    end
  end
end

-- Tag the next codediff tab as prtour-owned (so the guard skips it).
local function claim_next_codediff_tab()
  local id
  id = vim.api.nvim_create_autocmd("User", {
    pattern = "CodeDiffOpen",
    once = true,
    callback = function(args)
      local tp = (args.data and args.data.tabpage) or vim.api.nvim_get_current_tabpage()
      pcall(vim.api.nvim_tabpage_set_var, tp, "prtour_codediff", true)
    end,
  })
  -- Self-destruct if codediff never fired (avoid claiming an unrelated diff).
  vim.defer_fn(function()
    pcall(vim.api.nvim_del_autocmd, id)
  end, 4000)
end

local function git_root()
  local ok, git = pcall(require, "codediff.core.git")
  if ok and git.get_git_root_sync then
    local root = git.get_git_root_sync(vim.fn.getcwd())
    if root then
      return root
    end
  end
  local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  return (vim.v.shell_error == 0 and out[1]) or vim.fn.getcwd()
end

---@param session table
function M.open_under_cursor(session)
  local cur = vim.api.nvim_win_get_cursor(0)[1]
  local a = session.anchors and session.anchors[cur]
  if not a then
    notify("Place the cursor on a diff line", vim.log.levels.WARN)
    return
  end

  local ok_view, view = pcall(require, "codediff.ui.view")
  if not ok_view then
    notify("codediff.nvim is not available")
    return
  end

  install_review_guard()

  local meta = session.meta
  local root = session.root or git_root()
  local ft = vim.filetype.match({ filename = a.path }) or ""

  local function open_with(base_rev, modified_rev)
    vim.schedule(function()
      claim_next_codediff_tab()
      local ok = pcall(view.create, {
        mode = "standalone",
        git_root = root,
        original_path = a.path,
        modified_path = a.path,
        original_revision = base_rev,
        modified_revision = modified_rev,
      }, ft)
      if not ok then
        notify("codediff could not open " .. a.path .. " (commits not available locally?)")
      else
        vim.notify("Opened " .. a.path .. " in codediff", vim.log.levels.INFO, { title = "prtour" })
      end
    end)
  end

  -- Local working-tree review: HEAD vs the file on disk.
  if session.mode == "local" then
    open_with("HEAD", "WORKING")
    return
  end

  local head = meta.headRefOid
  local base_ref = meta.baseRefName and ("origin/" .. meta.baseRefName) or nil
  if not head then
    notify("PR head commit unknown")
    return
  end
  local spinner = require("prtour.spinner").cmdline("Fetching PR commits for codediff…")
  local function open_pr(base_rev)
    spinner:stop()
    open_with(base_rev, head)
  end

  -- Best-effort: fetch the PR head (works for forks too) + the base branch,
  -- then compute the merge-base so the diff matches GitHub's.
  local fetch = { "git", "-C", root, "fetch", "-q", "origin",
    string.format("pull/%d/head", session.number) }
  if meta.baseRefName then
    table.insert(fetch, meta.baseRefName)
  end
  vim.system(fetch, { text = true }, function()
    if not base_ref then
      open_pr(head .. "~1")
      return
    end
    vim.system({ "git", "-C", root, "merge-base", base_ref, head }, { text = true }, function(res)
      local base_rev = base_ref
      if res.code == 0 then
        local mb = (res.stdout or ""):gsub("%s+$", "")
        if mb ~= "" then
          base_rev = mb
        end
      end
      open_pr(base_rev)
    end)
  end)
end

return M
