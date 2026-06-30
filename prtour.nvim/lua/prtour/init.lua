local M = {}

local initialized = false

---@param opts? PrTourConfig
function M.setup(opts)
  require("prtour.config").setup(opts)
  require("prtour.render").setup_highlights()

  -- Reuse review.nvim's highlight groups for comment boxes if available.
  local ok, hl = pcall(require, "review.highlights")
  if ok then
    hl.setup()
  end

  if not initialized then
    vim.api.nvim_create_user_command("PrTour", function(args)
      M.dispatch(args.fargs)
    end, {
      nargs = "*",
      desc = "PR code tour",
      complete = function()
        return { "open", "url", "local", "refresh", "comments", "codediff", "push", "approve", "request-changes", "export", "close" }
      end,
    })
    initialized = true
  end
end

---@param fargs string[]
function M.dispatch(fargs)
  if not initialized then
    M.setup()
  end
  local tour = require("prtour.tour")
  local sub = fargs[1]

  -- No arg, or a bare number.
  if not sub then
    require("prtour.picker").open(function(number)
      tour.open(number)
    end)
    return
  end

  local subcommands = {
    open = true, url = true, ["local"] = true, refresh = true, comments = true,
    codediff = true, push = true, approve = true, ["request-changes"] = true,
    export = true, close = true,
  }

  if sub == "local" then
    tour.open_local()
    return
  end

  -- Anything that isn't a known subcommand is treated as a PR ref
  -- (bare number, github PR URL, or owner/repo#number).
  if not subcommands[sub] then
    tour.open(sub)
    return
  end

  if sub == "open" then
    if fargs[2] then
      tour.open(fargs[2])
    else
      require("prtour.picker").open(function(number)
        tour.open(number)
      end)
    end
    return
  end

  if sub == "url" then
    vim.ui.input({ prompt = "PR URL or owner/repo#number: " }, function(input)
      if input and input ~= "" then
        tour.open(input)
      end
    end)
    return
  end

  local session = tour.current
  if not session then
    vim.notify("No active tour", vim.log.levels.WARN, { title = "prtour" })
    return
  end

  if sub == "refresh" then
    if session.mode == "local" then
      tour.open_local(true)
    else
      tour.open(session.ref or session.number, true)
    end
  elseif sub == "comments" then
    tour.load_github_comments(session, true)
  elseif sub == "codediff" then
    require("prtour.codediff").open_under_cursor(session)
  elseif sub == "export" then
    require("prtour.export").to_clipboard(session)
  elseif sub == "close" then
    tour.close(session)
  elseif sub == "approve" then
    require("prtour.review").submit(session, "APPROVE")
  elseif sub == "request-changes" then
    require("prtour.review").submit(session, "REQUEST_CHANGES")
  elseif sub == "push" then
    require("prtour.review").submit(session, "COMMENT")
  else
    vim.notify("Unknown subcommand: " .. sub, vim.log.levels.ERROR, { title = "prtour" })
  end
end

return M
