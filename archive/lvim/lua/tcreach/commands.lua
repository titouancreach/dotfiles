vim.api.nvim_create_user_command('MigrateCreate', function(opt)
    local name = opt.args or nil
    vim.cmd('tabnew | set buftype=nowrite | r !../Scripts/create-migration.sh ' .. name)
end, { nargs = 1 })

vim.api.nvim_create_user_command('Migrate', function(opt)
    vim.cmd('!../Scripts/migrate.sh')
end, { nargs = 0 })

vim.api.nvim_create_user_command('BufOnly', function(opt)
    vim.cmd('%bd|e#|bd#')
end, { nargs = 0 })
