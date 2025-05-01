local helper = require('handmade.debug_helpers')

return {
    'mfussenegger/nvim-dap',
    version = '*',
    config = function ()
        local dap = require("dap")
        dap.adapters.cppdbg = {
            id = 'cppdbg',
            type = 'executable',
            command = helper.get_executable_path('mason/bin/OpenDebugAD7')
        }
        dap.adapters.codelldb = {
            id = 'codelldb',
            type = 'executable',
            command = helper.get_executable_path('mason/bin/codelldb')
        }
        dap.configurations.cpp = {
            {
                name = "Launch without arguments",
                type = "codelldb",
                request = "launch",
                program = function()
                    return helper.get_or_input('launch-program', 'Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                stopOnEntry = false,
                sourceLanguages = {"c", "cpp"},
            },
            {
                name = "Launch without arguments (stdio redirect)",
                type = "codelldb",
                request = "launch",
                program = function()
                    return helper.get_or_input('launch-program', 'Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end,
                stopOnEntry = false,
                sourceLanguages = {"c", "cpp"},
                stdio = function() return {
                    helper.get_or_input_nil("stdin", "stdin: "),
                    helper.get_or_input_nil("stdout", "stdout: "),
                    helper.get_or_input_nil("stderr", "stderr: "),
                } end,
            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

    end
}
