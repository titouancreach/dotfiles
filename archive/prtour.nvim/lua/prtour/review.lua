-- Submit the local comments to GitHub as a PR review (approve / request changes / comment).
local M = {}

local store = require("prtour.store")
local gh = require("prtour.gh")

local function type_name(t)
  local types = require("prtour.config").get().comment_types
  return (types[t] and types[t].name) or t
end

local EVENT_LABEL = {
  APPROVE = "Approve",
  REQUEST_CHANGES = "Request changes",
  COMMENT = "Comment",
}

-- Split comments into GitHub inline payloads and a leftover list (file-level /
-- non-line comments that can't be inline).
---@param session table
local function build_payload(session, event, body)
  local inline = {}
  local leftover = {}
  for _, c in ipairs(store.get_all()) do
    local gh_side = (c.side == "old") and "LEFT" or "RIGHT"
    if c.line and c.line > 0 then
      local item = {
        path = c.file,
        side = gh_side,
        line = c.line_end or c.line,
        body = string.format("**%s:** %s", type_name(c.type), c.text),
      }
      if c.line_end and c.line_end ~= c.line then
        item.start_line = c.line
        item.start_side = gh_side
      end
      table.insert(inline, item)
    else
      table.insert(leftover, string.format("- **%s:** `%s` — %s", type_name(c.type), c.file, c.text))
    end
  end

  local body_parts = {}
  if body and body ~= "" then
    table.insert(body_parts, body)
  end
  if #leftover > 0 then
    table.insert(body_parts, "File-level notes:\n" .. table.concat(leftover, "\n"))
  end

  return {
    commit_id = session.meta.headRefOid,
    event = event,
    body = table.concat(body_parts, "\n\n"),
    comments = inline,
  }, #inline, #leftover
end

---@param session table
---@param event "APPROVE"|"REQUEST_CHANGES"|"COMMENT"
function M.submit(session, event)
  if session.mode == "local" then
    vim.notify("Local review — no GitHub PR to submit to. Use C / q to export comments.",
      vim.log.levels.WARN, { title = "prtour" })
    return
  end
  local label = EVENT_LABEL[event] or event

  local function go(body)
    local payload, n_inline, n_left = build_payload(session, event, body)
    -- GitHub accepts a comment/request-changes review with just inline comments
    -- and no summary. Only block when there is genuinely nothing to send.
    if payload.body == "" and n_inline == 0 and n_left == 0 then
      vim.notify("Nothing to submit — add a comment or a summary", vim.log.levels.WARN, { title = "prtour" })
      return
    end
    local prompt = string.format(
      "%s PR #%d with %d inline comment(s)%s?",
      label, session.number, n_inline,
      n_left > 0 and (" + " .. n_left .. " file-level note(s)") or ""
    )
    local choice = vim.fn.confirm(prompt, "&Yes\n&No", 2)
    if choice ~= 1 then
      vim.notify("Cancelled", vim.log.levels.INFO, { title = "prtour" })
      return
    end
    gh.post_review(session.repo, session.number, payload, function(_, err)
      if err then
        vim.notify("GitHub review failed: " .. err, vim.log.levels.ERROR, { title = "prtour" })
        return
      end
      vim.notify(string.format("%s submitted to PR #%d ✓", label, session.number), vim.log.levels.INFO, { title = "prtour" })
    end)
  end

  -- The summary is always optional (Enter to skip) — inline comments alone are
  -- enough. GitHub may still reject an empty body for REQUEST_CHANGES with no
  -- comments; that error is surfaced if it happens.
  vim.ui.input({ prompt = label .. " summary (optional, Enter to skip): " }, function(body)
    go(body or "")
  end)
end

return M
