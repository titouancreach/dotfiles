vim.api.nvim_create_user_command('MigrateCreate', function(opt)
    local name = opt.args or nil
    vim.cmd('tabnew | r !../Scripts/create-migration.sh ' .. name)
end, { nargs = 1 })
