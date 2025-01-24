local function get_executable_path(path)
    if vim.fn.has("win32") ~= 0 then
        return vim.fn.expand("~") .. "/AppData/Local/nvim-data/" .. path .. ".exe"
    else
        return vim.fn.expand("~") .. "/.local/share/nvim/" .. path
    end
end

return {
    'mfussenegger/nvim-dap',
    version = '*',
    config = function ()
        local dap = require("dap")
        dap.adapters.cppdbg = {
            id = 'cppdbg',
            type = 'executable',
            command = get_executable_path('mason/bin/OpenDebugAD7')
        }
        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "cppdbg",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                runInTerminal = true,
                cwd = "${workspaceFolder}",
                stopAtEntry = true,
                setupCommands = {
                    {
                        text = '-enable-pretty-printing',
                        description =  'enable pretty printing',
                        ignoreFailures = false
                    },
                },
            }
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

    end
}
