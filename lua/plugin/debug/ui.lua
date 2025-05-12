return {
    "igorlfs/nvim-dap-view",
    -- dir = "~/projects/pet/nvim-dap-view/",
    dependencies = {
        'mfussenegger/nvim-dap',
        'theHamsta/nvim-dap-virtual-text',
    },
    config = function()
        local dv = require("dap-view")
        local dap = require("dap")
        -- dap.defaults.fallback.terminal_win_cmd = 'split new'
        require('nvim-dap-virtual-text').setup({})
        dv.setup({
            winbar = {
                show = true,
                -- You can add a "console" section to merge the terminal with the other views
                sections = { "watches", "scopes", "breakpoints", "threads", "repl" },
                -- Must be one of the sections declared above
                default_section = "watches",
                headers = {
                    breakpoints = "Breakpoints [B]",
                    scopes = "Scopes [S]",
                    exceptions = "Exceptions [E]",
                    watches = "Watches [W]",
                    threads = "Threads [T]",
                    repl = "REPL [R]",
                    console = "Console [C]",
                },
                controls = {
                    enabled = false,
                    position = "right",
                    buttons = {
                        "play",
                        "step_into",
                        "step_over",
                        "step_out",
                        "step_back",
                        "run_last",
                        "terminate",
                        "disconnect",
                    },
                    icons = {
                        pause = "",
                        play = "",
                        step_into = "",
                        step_over = "",
                        step_out = "",
                        step_back = "",
                        run_last = "",
                        terminate = "",
                        disconnect = "",
                    },
                    custom_buttons = {},
                },
            },
            windows = {
                height = 30,
                position = "right",
                terminal = {
                    -- 'left'|'right'|'above'|'below': Terminal position in layout
                    position = "below",
                    -- List of debug adapters for which the terminal should be ALWAYS hidden
                    hide = {},
                    width = 80,
                    -- Hide the terminal when starting a new session
                    start_hidden = false,
                },
            },
            -- Controls how to jump when selecting a breakpoint or navigating the stack
            switchbuf = "usetab,newtab",
        })

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
    end
}
