return {
    "igorlfs/nvim-dap-view",
    dev = true,
    dependencies = {
        'mfussenegger/nvim-dap',
        'theHamsta/nvim-dap-virtual-text',
    },
    config = function ()
        local dap, dv = require("dap"), require("dap-view")
        -- dap.defaults.fallback.terminal_win_cmd = 'split new'
        require('nvim-dap-virtual-text').setup({})

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
