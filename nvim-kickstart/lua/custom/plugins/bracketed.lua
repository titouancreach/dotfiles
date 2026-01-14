return {
  {
    'echasnovski/mini.bracketed',
    version = false,
    config = function()
      require('mini.bracketed').setup({
        comment = { suffix = '' }, -- Disable comment navigation (conflicts with gitsigns hunks)
      })

      -- AZERTY-friendly mappings: < for next (]), > for previous ([)
      local targets = {
        { 'b', 'buffer' },
        { 'x', 'conflict' },
        { 'd', 'diagnostic' },
        { 'f', 'file' },
        { 'i', 'indent' },
        { 'j', 'jump' },
        { 'l', 'location' },
        { 'o', 'oldfile' },
        { 'q', 'quickfix' },
        { 't', 'treesitter' },
        { 'u', 'undo' },
        { 'w', 'window' },
        { 'y', 'yank' },
      }

      for _, target in ipairs(targets) do
        local suffix, name = target[1], target[2]
        -- < for next (like ])
        vim.keymap.set('n', '<' .. suffix, ']' .. suffix, { desc = 'Next ' .. name, remap = true })
        vim.keymap.set('n', '<' .. suffix:upper(), ']' .. suffix:upper(), { desc = 'Last ' .. name, remap = true })
        -- > for previous (like [)
        vim.keymap.set('n', '>' .. suffix, '[' .. suffix, { desc = 'Previous ' .. name, remap = true })
        vim.keymap.set('n', '>' .. suffix:upper(), '[' .. suffix:upper(), { desc = 'First ' .. name, remap = true })
      end
    end,
  },
}
