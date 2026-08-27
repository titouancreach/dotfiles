local hooks = require("review.hooks")

describe("hooks focus behavior", function()
  local mod_buf, mod_win, other_win

  before_each(function()
    mod_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(mod_buf, 0, -1, false, { "new line" })

    other_win = vim.api.nvim_get_current_win()

    vim.cmd("vsplit")
    mod_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(mod_win, mod_buf)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(mod_buf) then
      vim.api.nvim_buf_delete(mod_buf, { force = true })
    end

    while #vim.api.nvim_tabpage_list_wins(0) > 1 do
      vim.cmd("quit")
    end
  end)

  it("focuses the modified pane normally", function()
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_set_current_win(other_win)
    assert.equals(other_win, vim.api.nvim_get_current_win())

    local lifecycle = {
      get_session = function()
        return { modified_win = mod_win }
      end,
    }

    hooks._focus_modified_pane(lifecycle, tabpage)

    assert.equals(mod_win, vim.api.nvim_get_current_win())
  end)

  it("should not steal focus from floating windows", function()
    local tabpage = vim.api.nvim_get_current_tabpage()
    vim.api.nvim_set_current_win(other_win)

    local lifecycle = {
      get_session = function()
        return { modified_win = mod_win }
      end,
    }

    -- Stub nvim_win_get_config to simulate current window being a float
    local original_get_config = vim.api.nvim_win_get_config
    vim.api.nvim_win_get_config = function(win)
      if win == vim.api.nvim_get_current_win() then
        return { relative = "cursor", width = 40, height = 5 }
      end
      return original_get_config(win)
    end

    hooks._focus_modified_pane(lifecycle, tabpage)

    -- Focus should stay on the current window, not jump to mod_win
    assert.equals(other_win, vim.api.nvim_get_current_win())

    vim.api.nvim_win_get_config = original_get_config
  end)
end)
