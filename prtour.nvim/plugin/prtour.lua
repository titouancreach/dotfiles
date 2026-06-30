if vim.g.loaded_prtour then
  return
end
vim.g.loaded_prtour = true

vim.api.nvim_create_user_command("PrTour", function(args)
  require("prtour").dispatch(args.fargs)
end, {
  nargs = "*",
  desc = "PR code tour",
  complete = function()
    return { "open", "url", "local", "refresh", "comments", "codediff", "push", "approve", "request-changes", "export", "close" }
  end,
})
