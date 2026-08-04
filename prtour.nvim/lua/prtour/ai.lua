-- Generate a "tour" spec (section ordering + prose) from a PR diff via the Claude CLI.
local M = {}

local LOW_SIGNAL_PATTERNS = {
  "package%-lock%.json$", "yarn%.lock$", "pnpm%-lock%.yaml$", "go%.sum$",
  "Cargo%.lock$", "composer%.lock$", "Gemfile%.lock$", "poetry%.lock$",
  "%.lock$", "%.snap$", "%.min%.js$", "%.min%.css$",
  "^dist/", "/dist/", "^build/", "/build/", "generated", "%.pb%.go$", "_pb2%.py$",
}

local function is_low_signal(path)
  for _, pat in ipairs(LOW_SIGNAL_PATTERNS) do
    if path:match(pat) then
      return true
    end
  end
  return false
end

-- A no-AI tour: one section with the substantive files, lockfiles/generated in Skim.
---@param files PrDiffFile[]
---@return table
function M.fallback_tour(files)
  local main, skim = {}, {}
  for _, f in ipairs(files) do
    if is_low_signal(f.path) then
      table.insert(skim, f.path)
    else
      table.insert(main, f.path)
    end
  end
  return {
    summary = "",
    sections = { { title = "Changes", signal = "med", description = "", files = main } },
    skim = skim,
  }
end

-- Keep the AI spec honest: drop unknown paths, funnel anything unmentioned into Skim.
---@param spec table
---@param files PrDiffFile[]
---@return table
local function reconcile(spec, files)
  local valid = {}
  for _, f in ipairs(files) do
    valid[f.path] = true
  end
  local seen = {}
  local sections = {}
  for _, sec in ipairs(spec.sections or {}) do
    local kept = {}
    for _, p in ipairs(sec.files or {}) do
      if valid[p] and not seen[p] then
        seen[p] = true
        table.insert(kept, p)
      end
    end
    if #kept > 0 then
      table.insert(sections, {
        title = sec.title or "Section",
        signal = (sec.signal == "high" or sec.signal == "med" or sec.signal == "low") and sec.signal or "med",
        description = sec.description or "",
        files = kept,
      })
    end
  end
  -- Order high -> med -> low, stable within tier.
  local rank = { high = 1, med = 2, low = 3 }
  local indexed = {}
  for i, s in ipairs(sections) do
    indexed[i] = { s = s, i = i }
  end
  table.sort(indexed, function(a, b)
    local ra, rb = rank[a.s.signal] or 2, rank[b.s.signal] or 2
    if ra ~= rb then
      return ra < rb
    end
    return a.i < b.i
  end)
  local ordered = {}
  for _, e in ipairs(indexed) do
    table.insert(ordered, e.s)
  end

  local skim = {}
  for _, p in ipairs(spec.skim or {}) do
    if valid[p] and not seen[p] then
      seen[p] = true
      table.insert(skim, p)
    end
  end
  for _, f in ipairs(files) do
    if not seen[f.path] then
      table.insert(skim, f.path)
    end
  end

  local ticket
  if type(spec.ticket) == "table" and (spec.ticket.title or spec.ticket.purpose) then
    ticket = {
      title = type(spec.ticket.title) == "string" and spec.ticket.title or nil,
      url = type(spec.ticket.url) == "string" and spec.ticket.url or nil,
      purpose = type(spec.ticket.purpose) == "string" and spec.ticket.purpose or nil,
    }
  end
  return { summary = spec.summary or "", ticket = ticket, sections = ordered, skim = skim }
end

local function val(v)
  if v == nil or v == vim.NIL then
    return nil
  end
  return v
end

-- Notion ticket URLs referenced anywhere in the PR (body / title / branch).
---@param meta table
---@return string[]
local function notion_urls(meta)
  local seen, out = {}, {}
  local function scan(s)
    if type(s) ~= "string" then
      return
    end
    for url in s:gmatch("https?://[%w%.%-]*notion%.[%w]+/[%w%-%./%?=&#]+") do
      url = url:gsub("[%)%.,]+$", "")
      if not seen[url] then
        seen[url] = true
        table.insert(out, url)
      end
    end
  end
  scan(val(meta.body))
  scan(val(meta.title))
  scan(val(meta.headRefName))
  return out
end

local PROMPT = [[
You are preparing a "code tour" for a pull request review. Group the changed files into a
few themed sections and order them so the reviewer reads the PR top-to-bottom: the
highest-signal changes first, trivial/generated changes last.

Output ONLY a JSON object (no markdown fences, no prose around it) with this shape:
{
  "summary": "at most one sentence: what this PR changes, in concrete terms",
  "ticket": { "title": "...", "url": "...", "purpose": "why this PR exists, from the ticket" },
  "sections": [
    {
      "title": "at most 5 words, naming the actual thing that changed",
      "signal": "high" | "med" | "low",
      "description": "ONE terse line a reviewer can act on",
      "files": ["exact/repo/relative/path.ext", ...]
    }
  ],
  "skim": ["low-signal/path", ...]
}

Write like a senior engineer leaving a one-line note for a teammate:
- Say the SINGLE thing that matters about the change — the substance a reviewer cares about.
  Drop incidental churn that rode along: an argument moving position, a call relocating
  (e.g. from `.pipe` to an argument), reordering, renames, formatting. Mention such a detail
  ONLY if it IS the point of the change. ("We added spans" — not "we added spans AND moved
  the error handler".)
- One idea per description. If you're about to add a second clause with ";" or "and …",
  it's almost always noise — cut it.
- Use the codebase's OWN vocabulary — the real function, type, and variable names and the
  domain terms that already appear in the diff. Refer to them verbatim (e.g. `OpportunityItem`).
- Do NOT invent words, metaphors, or labels for concepts (no "gate", "wire"/"wires"/
  "wiring", "glue", "plumbing", "machinery", "orchestration", "hook up"). If the code
  calls it X, call it X.
- State the concrete mechanism — what the code now does differently — not abstract impact.
  Avoid "improves", "enables", "ensures", "allows", "robust", "cleanly", "properly".
- No filler: drop "this PR", "this change", "notably", "essentially", "in order to".
- One line per description. If you can't say something useful, keep it shorter, not longer.

Rules:
- Use the EXACT file paths from the diff.
- Every changed file must appear exactly once, in a section's "files" or in "skim".
- Prefer 2-6 sections. Put lockfiles/generated/formatting-only files in "skim".
- "ticket": ONLY include it if a Notion ticket URL is provided below. Fetch that page with
  your Notion tool, then set "title", "url", and a 1-2 sentence "purpose" (why this PR
  exists / the problem it solves, from the ticket — not a restatement of the diff). If no
  URL is given, or you cannot fetch it, OMIT "ticket" entirely.
]]

-- Appended when the humanizer skill is enabled: run it over the prose fields as
-- a second pass, but keep the JSON-only output contract intact.
local function humanize_block(skill)
  return string.format([[

Humanize the prose before you finish:
- After you have drafted the JSON, invoke the `%s` skill (via the Skill tool) to
  load its guidance, then apply that guidance to the human-readable text fields:
  "summary", every section "description", and "ticket.purpose".
- The skill's own draft / audit-bullets / final-rewrite output format is for its
  internal use ONLY. Do NOT print any of it. Your ONLY output is the final JSON
  object described above: no fences, no commentary, nothing before or after it.
- The skill rewrites text, not structure. Keep the JSON shape, the exact file
  paths, and every rule above intact.
- If the skill cannot be found, skip this step and output the JSON as usual.
]], skill)
end

-- Build the stdin prompt for Claude.
local function build_prompt(meta, diff_text, ticket_urls, humanize_skill)
  local parts = {
    PROMPT,
  }
  if humanize_skill and humanize_skill ~= "" then
    table.insert(parts, humanize_block(humanize_skill))
  end
  table.insert(parts, string.format("\nPR #%d: %s\n", meta.number or 0, meta.title or ""))
  if ticket_urls and #ticket_urls > 0 then
    table.insert(parts, "\nLinked Notion ticket(s) — fetch with your Notion tool for the \"ticket\" field:\n  "
      .. table.concat(ticket_urls, "\n  ") .. "\n")
  end
  if type(meta.body) == "string" and meta.body ~= "" then
    table.insert(parts, "PR description:\n" .. meta.body .. "\n")
  end
  table.insert(parts, "\nUnified diff:\n")
  table.insert(parts, diff_text)
  return table.concat(parts)
end

local function strip_fences(s)
  s = s:gsub("^%s*```%w*%s*", ""):gsub("%s*```%s*$", "")
  return s
end

local cache_dir = vim.fn.stdpath("data") .. "/prtour"
-- Bump when the prompt/output shape changes, to invalidate stale cached tours.
local TOUR_VERSION = 5

---@param head_oid string|nil
local function cache_path(head_oid)
  if not head_oid or head_oid == "" then
    return nil
  end
  return string.format("%s/tour-v%d-%s.json", cache_dir, TOUR_VERSION, head_oid)
end

-- Return a cached tour for this head commit, or nil.
---@param head_oid string|nil
function M.load_cached(head_oid)
  local path = cache_path(head_oid)
  if not path then
    return nil
  end
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  local ok, tour = pcall(vim.json.decode, content or "")
  if ok and type(tour) == "table" and tour.sections then
    return tour
  end
  return nil
end

---@param head_oid string|nil
---@param tour table
function M.save_cached(head_oid, tour)
  local path = cache_path(head_oid)
  if not path then
    return
  end
  pcall(vim.fn.mkdir, cache_dir, "p")
  local f = io.open(path, "w")
  if f then
    f:write(vim.json.encode(tour))
    f:close()
  end
end

M._notion_urls = notion_urls

-- Generate a tour. Always calls cb with a valid spec (falls back on any error).
---@param meta table
---@param files PrDiffFile[]
---@param diff_text string
---@param cb fun(tour: table, ai_used: boolean)
function M.generate_tour(meta, files, diff_text, cb)
  local cfg = require("prtour.config").get()
  local cmd = vim.deepcopy(cfg.claude_cmd)
  -- Inject a (faster) model unless the user already pinned one in claude_cmd.
  if cfg.model and cfg.model ~= "" and not vim.tbl_contains(cmd, "--model") then
    table.insert(cmd, "--model")
    table.insert(cmd, cfg.model)
  end

  -- Tools the headless claude may call, gathered so we pass --allowedTools once.
  local allowed = {}

  -- If the PR links a Notion ticket and the integration is on, let claude fetch it.
  local urls = {}
  if cfg.notion and cfg.notion.enabled then
    urls = notion_urls(meta)
    if #urls > 0 and cfg.notion.tools and #cfg.notion.tools > 0 then
      vim.list_extend(allowed, cfg.notion.tools)
    end
  end

  -- If humanizing is on, allow the Skill tool so claude can invoke the skill.
  local humanize_skill
  if cfg.humanize and cfg.humanize.enabled and cfg.humanize.skill and cfg.humanize.skill ~= "" then
    humanize_skill = cfg.humanize.skill
    table.insert(allowed, "Skill")
  end

  if #allowed > 0 then
    table.insert(cmd, "--allowedTools")
    table.insert(cmd, table.concat(allowed, ","))
  end

  local prompt = build_prompt(meta, diff_text, urls, humanize_skill)

  vim.system(cmd, { text = true, stdin = prompt }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        cb(M.fallback_tour(files), false)
        return
      end
      local ok_env, env = pcall(vim.json.decode, res.stdout)
      local text = ok_env and type(env) == "table" and env.result or res.stdout
      local ok_spec, spec = pcall(vim.json.decode, strip_fences(text or ""))
      if not ok_spec or type(spec) ~= "table" or not spec.sections then
        cb(M.fallback_tour(files), false)
        return
      end
      cb(reconcile(spec, files), true)
    end)
  end)
end

return M
