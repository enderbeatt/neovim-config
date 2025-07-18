local helper = require('handmade.debug_helpers')

return {
    'mfussenegger/nvim-dap',
    dependencies = {
        "igorlfs/nvim-dap-view",
    },
    version = '*',
    config = function ()
        local dap = require("dap")
        local dv = require("dap-view")
        dap.listeners.before.attach["dap-view-config"] = function()
            dv.open()
        end
        dap.listeners.before.launch["dap-view-config"] = function()
            dv.open()
        end
        dap.listeners.before.event_terminated["dap-view-config"] = function()
            dv.close(true)
        end
        dap.listeners.before.event_exited["dap-view-config"] = function()
            dv.close(true)
        end

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
                    return helper.get_or('launch-program', helper.pick_executable())
                end,
                stopOnEntry = false,
                sourceLanguages = {"c", "cpp"},
            },
            {
                name = "Launch without arguments (stdio redirect)",
                type = "codelldb",
                request = "launch",
                program = function()
                    return helper.get_or('launch-program', helper.pick_executable())
                end,
                stopOnEntry = false,
                sourceLanguages = {"c", "cpp"},
                stdio = function() return {
                    helper.get_or_nil("stdin", helper.input("stdin: ")),
                    helper.get_or_nil("stdout", helper.input("stdout: ")),
                    helper.get_or_nil("stderr", helper.input("stderr: ")),
                } end,
            },
        }
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = {
            {
                name = "Launch without arguments",
                type = "codelldb",
                request = "launch",
                program = function()
                    return helper.get_or('launch-program', helper.pick_executable())
                end,
                stopOnEntry = false,
                sourceLanguages = {"rust"},
            },
            {
                name = "Launch without arguments (stdio redirect)",
                type = "codelldb",
                request = "launch",
                program = function()
                    return helper.get_or('launch-program', helper.pick_executable())
                end,
                stopOnEntry = false,
                sourceLanguages = {"rust"},
                stdio = function() return {
                    helper.get_or_input_nil("stdin", "stdin: "),
                    helper.get_or_input_nil("stdout", "stdout: "),
                    helper.get_or_input_nil("stderr", "stderr: "),
                } end,
            },
        }

        vim.api.nvim_create_user_command("DebugUpdateValue", function (opts)
            helper.update_str(opts.fargs[1])
        end, {
            nargs = 1,
            complete = function (ArgLead, _, _)
                local matches = {}
                for key, _ in pairs(helper.values) do
                    if vim.startswith(key, ArgLead) then
                        table.insert(matches, key)
                    end
                end
                return matches
            end
        })

    end
}
