local dap = require("dap")

dap.adapters.coreclr = {
    type = 'executable',
    command = '/Users/tcreach/bin/netcoredbg/netcoredbg',
    args = { '--interpreter=vscode' }
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            ---@diagnostic disable-next-line: redundant-parameter
            return vim.fn.input('Path to DLL > ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
        end,
    },
}

require('dap.ext.vscode').load_launchjs(nil, {})
