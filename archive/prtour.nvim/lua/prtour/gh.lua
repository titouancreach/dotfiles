-- Async wrappers around the `gh` CLI.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.ERROR, { title = "prtour" })
end

-- Run a command with vim.system, decoding stdout as JSON (or raw if json=false).
---@param cmd string[]
---@param opts { json?: boolean, input?: string }
---@param cb fun(result: any|nil, err: string|nil)
local function run(cmd, opts, cb)
  opts = opts or {}
  local sys_opts = { text = true }
  if opts.input then
    sys_opts.stdin = opts.input
  end
  vim.system(cmd, sys_opts, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        cb(nil, (res.stderr ~= "" and res.stderr or res.stdout) or ("exit " .. res.code))
        return
      end
      if opts.json == false then
        cb(res.stdout, nil)
        return
      end
      local ok, decoded = pcall(vim.json.decode, res.stdout)
      if not ok then
        cb(nil, "failed to parse JSON: " .. tostring(decoded))
        return
      end
      cb(decoded, nil)
    end)
  end)
end

-- PRs where the current user is requested as reviewer.
---@param search string
---@param cb fun(prs: table[]|nil, err: string|nil)
function M.list_review_requested(search, cb)
  local fields =
    "number,title,author,additions,deletions,changedFiles,updatedAt,headRefName,baseRefName,headRefOid,url"
  run({
    "gh", "pr", "list",
    "--search", search,
    "--state", "open",
    "--limit", "100",
    "--json", fields,
  }, { json = true }, cb)
end

---@param number integer
---@param cb fun(meta: table|nil, err: string|nil)
function M.pr_meta(number, cb)
  local fields = "number,title,body,author,headRefOid,baseRefName,headRefName,"
    .. "headRepository,headRepositoryOwner,additions,deletions,changedFiles,url"
  run({ "gh", "pr", "view", tostring(number), "--json", fields }, { json = true }, cb)
end

---@param number integer
---@param cb fun(diff: string|nil, err: string|nil)
function M.pr_diff(number, cb)
  run({ "gh", "pr", "diff", tostring(number) }, { json = false }, cb)
end

-- Raw file content at a commit (for expanding hidden diff context).
---@param repo string  "owner/name" (the head repo, for fork support)
---@param ref string   commit sha
---@param path string
---@param cb fun(content: string|nil, err: string|nil)
function M.file_content(repo, ref, path, cb)
  local endpoint = string.format("repos/%s/contents/%s?ref=%s", repo, path, ref)
  run({ "gh", "api", "-H", "Accept: application/vnd.github.raw", endpoint }, { json = false }, cb)
end

-- Existing inline review comments on a PR.
---@param repo string  "owner/name"
---@param number integer
---@param cb fun(comments: table[]|nil, err: string|nil)
function M.list_review_comments(repo, number, cb)
  local endpoint = string.format("repos/%s/pulls/%d/comments?per_page=100", repo, number)
  run({ "gh", "api", "--paginate", endpoint }, { json = true }, cb)
end

---@param cb fun(name_with_owner: string|nil, err: string|nil)
function M.repo(cb)
  run({ "gh", "repo", "view", "--json", "nameWithOwner" }, { json = true }, function(res, err)
    if err then
      cb(nil, err)
      return
    end
    cb(res.nameWithOwner, nil)
  end)
end

-- Post a review to a PR.
---@param repo string  "owner/name"
---@param number integer
---@param payload { commit_id: string, event: string, body: string, comments: table[] }
---@param cb fun(result: table|nil, err: string|nil)
function M.post_review(repo, number, payload, cb)
  if not repo then
    cb(nil, "could not determine repo")
    return
  end
  local endpoint = string.format("repos/%s/pulls/%d/reviews", repo, number)
  local body = vim.json.encode(payload)
  run({ "gh", "api", "--method", "POST", endpoint, "--input", "-" }, { json = true, input = body }, cb)
end

M._notify = notify

return M
