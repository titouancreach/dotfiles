-- Tiny animated spinner: command-line mode (for fetches) and buffer mode
-- (a virtual line pinned above the tour while Claude works).
local M = {}

local FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local uv = vim.uv or vim.loop

local function new_timer(on_tick)
  local timer = uv.new_timer()
  local i = 0
  timer:start(0, 90, vim.schedule_wrap(function()
    i = (i % #FRAMES) + 1
    on_tick(FRAMES[i])
  end))
  return timer
end

-- Spinner on the command line. Returns a handle with :stop(final_msg?).
---@param msg string
function M.cmdline(msg)
  local timer = new_timer(function(frame)
    vim.api.nvim_echo({ { frame .. " " .. msg, "WarningMsg" } }, false, {})
  end)
  return {
    stop = function(_, final)
      pcall(function()
        timer:stop()
        timer:close()
      end)
      if final then
        vim.api.nvim_echo({ { final, "Comment" } }, false, {})
      else
        vim.api.nvim_echo({ { "" } }, false, {})
      end
    end,
  }
end

-- Spinner pinned above the top line of a buffer. Returns a handle with :stop().
---@param bufnr integer
---@param msg string
function M.buffer(bufnr, msg)
  local ns = vim.api.nvim_create_namespace("prtour_spinner")
  local timer = new_timer(function(frame)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {
      virt_lines_above = true,
      virt_lines = { { { "  " .. frame .. " " .. msg, "PrTourMed" } } },
    })
  end)
  return {
    stop = function()
      pcall(function()
        timer:stop()
        timer:close()
      end)
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end
    end,
  }
end

return M
