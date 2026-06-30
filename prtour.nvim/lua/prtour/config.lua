local M = {}

---@class PrTourConfig
---@field keymaps table<string, string|false>
---@field claude_cmd string[]
---@field search string
---@field skim_folded boolean

---@type PrTourConfig
M.defaults = {
  -- Buffer-local keymaps in the tour buffer. Set any to false to disable.
  keymaps = {
    add_comment = "i", -- add comment at cursor (visual range supported)
    edit_comment = "e",
    delete_comment = "d",
    next_comment = "]n",
    prev_comment = "[n",
    next_section = "<Tab>",
    prev_section = "<S-Tab>",
    toggle_fold = "za",
    open_fold = "<CR>",
    yank_context = "y", -- yank file:line + hunk for Claude
    open_codediff = "D", -- open file under cursor in codediff (base..head)
    reload_comments = "gP", -- re-fetch GitHub review comments
    export_clipboard = "C",
    approve = "<leader>a",
    request_changes = "<leader>r",
    push = "<leader>p",
    refresh = "<leader>R",
    close = "q",
    help = "g?",
  },
  -- How to invoke the Claude CLI for tour generation.
  claude_cmd = { "claude", "-p", "--output-format", "json" },
  -- Model for tour generation. A fast model keeps the wait short; the tour is
  -- cached per head commit so reopening is instant. Set "" to use your default.
  model = "sonnet",
  -- Semantic comment labels (m31coding "semantic reviews"), ordered by
  -- escalating expectation. Each conveys intent + what response is expected.
  comment_types = {
    remark     = { name = "Remark",     icon = "💬", hl = "PrTourRemark" },
    hint       = { name = "Hint",       icon = "💡", hl = "PrTourHint" },
    question   = { name = "Question",   icon = "❓", hl = "PrTourQuestion" },
    suggestion = { name = "Suggestion", icon = "🔧", hl = "PrTourSuggestion" },
    important  = { name = "Important",  icon = "❗", hl = "PrTourImportant" },
    crucial    = { name = "Crucial",    icon = "🛑", hl = "PrTourCrucial" },
  },
  comment_type_order = { "remark", "hint", "question", "suggestion", "important", "crucial" },
  -- Comment editor: "buffer" = a real editable split (:wq save / :q discard,
  -- full vim motions); "popup" = review.nvim's nui popup (<C-s> submit).
  comment_ui = "buffer",
  -- If the PR links a Notion ticket, let the headless `claude` fetch it (via the
  -- Notion MCP) and explain the PR's purpose at the top of the tour.
  notion = {
    enabled = true,
    -- MCP tool names `claude -p` is allowed to call to read the ticket.
    tools = { "mcp__claude_ai_Notion__notion-fetch", "mcp__claude_ai_Notion__notion-search" },
  },
  -- gh search filter for the picker.
  search = "review-requested:@me",
  -- Whether the low-signal "Skim" section starts folded.
  skim_folded = true,
}

---@type PrTourConfig
M.config = vim.deepcopy(M.defaults)

---@param opts? PrTourConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

---@return PrTourConfig
function M.get()
  return M.config
end

return M
