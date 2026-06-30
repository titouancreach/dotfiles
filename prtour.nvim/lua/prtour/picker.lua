-- Telescope picker over PRs where you're requested as reviewer.
local M = {}

local gh = require("prtour.gh")

local function fmt_entry(pr)
  return string.format("#%d  %s  +%d -%d  @%s",
    pr.number, pr.title, pr.additions or 0, pr.deletions or 0,
    (pr.author and pr.author.login) or "?")
end

local function fallback_select(prs, on_choice)
  vim.ui.select(prs, {
    prompt = "Review-requested PRs",
    format_item = fmt_entry,
  }, function(pr)
    if pr then
      on_choice(pr.number)
    end
  end)
end

function M.open(on_choice)
  local cfg = require("prtour.config").get()
  local spinner = require("prtour.spinner").cmdline("Loading review-requested PRs…")
  gh.list_review_requested(cfg.search, function(prs, err)
    spinner:stop()
    if not prs then
      vim.notify("gh pr list failed: " .. (err or ""), vim.log.levels.ERROR, { title = "prtour" })
      return
    end
    if #prs == 0 then
      vim.notify("No PRs awaiting your review (" .. cfg.search .. ")", vim.log.levels.INFO, { title = "prtour" })
      return
    end

    local ok = pcall(require, "telescope")
    if not ok then
      fallback_select(prs, on_choice)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    pickers.new({}, {
      prompt_title = "Review-requested PRs",
      finder = finders.new_table({
        results = prs,
        entry_maker = function(pr)
          return {
            value = pr,
            display = fmt_entry(pr),
            ordinal = string.format("%d %s %s", pr.number, pr.title, (pr.author and pr.author.login) or ""),
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "PR diff",
        define_preview = function(self, entry)
          gh.pr_diff(entry.value.number, function(diff_text)
            if diff_text and vim.api.nvim_buf_is_valid(self.state.bufnr) then
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(diff_text, "\n", { plain = true }))
              vim.bo[self.state.bufnr].filetype = "diff"
            end
          end)
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            on_choice(entry.value.number)
          end
        end)
        return true
      end,
    }):find()
  end)
end

return M
