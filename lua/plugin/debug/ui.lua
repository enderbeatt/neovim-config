return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        'mfussenegger/nvim-dap',
        "nvim-neotest/nvim-nio",
        'theHamsta/nvim-dap-virtual-text',
    },
    config = function ()
        local dap = require('dap')

        local dapui = require("dapui")
        dapui.setup({
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "",
                    pause = "",
                    play = "",
                    run_last = "",
                    step_back = "",
                    step_into = "",
                    step_out = "",
                    step_over = "",
                    terminate = ""
                }
            },
            element_mappings = {},
            expand_lines = true,
            floating = {
                border = "single",
                mappings = {
                    close = { "<Esc>", "q" }
                }
            },
            force_buffers = true,
            icons = {
                collapsed = "",
                current_frame = "",
                expanded = ""
            },
            layouts = { {
                elements = { {
                    id = "watches",
                    size = 0.25
                }, {
                        id = "scopes",
                        size = 0.25
                    }, {
                        id = "breakpoints",
                        size = 0.25
                    }, {
                        id = "stacks",
                        size = 0.25
                    } },
                position = "right",
                size = 60
            }, {
                    elements = { {
                        id = "console",
                        size = 0.50
                    }, {
                            id = "repl",
                            size = 0.50
                        } },
                    position = "bottom",
                    size = 12
                } },
            mappings = {
                edit = "e",
                expand = { "<CR>", "<2-LeftMouse>" },
                open = "o",
                remove = "d",
                repl = "r",
                toggle = "t"
            },
            render = {
                indent = 1,
                max_value_lines = 100
            }
        }
        )

        dap.set_log_level('trace')
        -- dap.defaults.fallback.terminal_win_cmd = 'split new'
        require('nvim-dap-virtual-text').setup({})

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end
}
