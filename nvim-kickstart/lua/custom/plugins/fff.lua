return {
  {
    'dmtrKovalenko/fff.nvim',
    -- Compiles (or downloads a prebuilt) Rust binary on install/update.
    build = function()
      require('fff.download').download_or_build_binary()
    end,
    -- Load at startup so frecency tracking sees every file you open,
    -- not just files opened after the first picker invocation.
    lazy = false,
    opts = {},
    keys = {
      -- Replaces Telescope's git_files file finder.
      { '<leader>sf', function() require('fff').find_files() end, desc = '[S]earch [F]iles (fff)' },
      -- Replaces Telescope's live_grep.
      { '<leader>/', function() require('fff').live_grep() end, desc = '[S]earch by Grep (fff)' },
    },
  },
}
