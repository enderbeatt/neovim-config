local helper = require('handmade.debug_helpers')

return {
    'mfussenegger/nvim-dap',
    enabled = false,
    dependencies = {
        "igorlfs/nvim-dap-view",
    },
    version = '*',
    opts = function()
        local adapters = {}
        adapters.cppdbg = {
            id = 'cppdbg',
            type = 'executable',
            command = helper.get_executable_path('mason/bin/OpenDebugAD7')
        }
        adapters.codelldb = {
            id = 'codelldb',
            type = 'executable',
            command = helper.get_executable_path('mason/bin/codelldb')
        }
        local configurations = {}
        configurations.cpp = {
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
        configurations.cpp[#configurations.cpp + 1] = {
            name = "Attach to running program (lldb)",
            type = "codelldb",
            request = "attach",
            pid = require('dap.utils').pick_process,
            stopOnEntry = false,
            sourceLanguages = {"c", "cpp"},
        }
        configurations.rust = {
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
                    helper.get_or_nil("stdin", helper.input("stdin: ")),
                    helper.get_or_nil("stdout", helper.input("stdout: ")),
                    helper.get_or_nil("stderr", helper.input("stderr: ")),
                } end,
            },
        }

        return { adapters = adapters, configurations = configurations }
    end,
    config = function(_, opts)
        local dap = require("dap")
        local dv = require("dap-view")
        dap.listeners.before.attach["dap-view-config"] = function()
            dv.open()
        end
        dap.listeners.before.launch["dap-view-config"] = function()
            dv.open()
        end
        for _, event in ipairs({ "disconnect", "event_terminated", "event_exited" }) do
            dap.listeners.before[event]["dap-view-config"] = function()
                dv.close(true)
            end
        end

        for name, adapter in pairs(opts.adapters) do
            dap.adapters[name] = adapter
        end
        for filetype, configurations in pairs(opts.configurations) do
            dap.configurations[filetype] = configurations
        end
        dap.configurations.c = dap.configurations.cpp

        vim.api.nvim_create_user_command("DebugUpdateValue", function (opts)
            vim.schedule(function()
                helper.update_str(opts.fargs[1])
            end)
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
