-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['Y'] = function(state)
            local node = state.tree:get_node()
            if not node or not node.id then
              vim.notify('No node selected.', vim.log.levels.WARN)
              return
            end

            if vim.fn.has 'clipboard' == 0 then
              vim.notify('System clipboard is not available.', vim.log.levels.ERROR)
              return
            end

            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local choices = {
              { label = 'Absolute path', value = filepath },
              { label = 'Path relative to CWD', value = modify(filepath, ':.') },
              { label = 'Path relative to HOME', value = modify(filepath, ':~') },
              { label = 'Filename', value = filename },
              { label = 'Filename without extension', value = modify(filename, ':r') },
              { label = 'Extension of the filename', value = modify(filename, ':e') },
            }

            vim.ui.select(choices, {
              prompt = 'Choose to copy to clipboard:',
              format_item = function(item)
                return string.format('%-30s %s', item.label, item.value)
              end,
            }, function(choice)
              if not choice then
                vim.notify('Copy cancelled.', vim.log.levels.INFO)
                return
              end

              local value_to_copy = choice.value

              vim.fn.setreg('+', value_to_copy)
              vim.notify('Copied to clipboard: ' .. value_to_copy)
            end)
          end,
        },
      },
    },
    window = {
      width = 70,
    },
  },
}
