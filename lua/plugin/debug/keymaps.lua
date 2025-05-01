---jump to the window of specified dapui element
---@param element string filetype of the element or 'code_win' for the code window
local function jump_to_element(element)
    local visible_wins = vim.api.nvim_tabpage_list_wins(0)
    local dap_configurations = require('dap').configurations
    for _, win in ipairs(visible_wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == element
            -- As we do not know the filetype of the code window, we have to check if
            -- we can find a window with a file type that is also in the dap.configurations
            -- We simply assume, that this is the code window
            or element == "code_win" and dap_configurations[vim.bo[buf].filetype] ~= nil
        then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    vim.notify(("element '%s' not found"):format(element), vim.log.levels.WARN)
end

return {
    "nvimtools/hydra.nvim",
    dependencies = {
        "rcarriga/nvim-dap-ui",
    },
    config = function ()
        local hydra = require('hydra')
        local dap = require('dap')
        local dapui = require("dapui")

        require('nvim-dap-virtual-text').setup({})
        hydra({
            name = "DEBUG",
            mode = "n",
            body = "<leader>d",
            config = {
                color = 'pink',
            },
            heads = {
                { "I", function ()
                    dap.continue()
                    vim.cmd([[:DapVirtualTextEnable]])
                end },
                { "J", function () dap.step_over() end },
                { "H", function () dap.step_out() end },
                { "L", function () dap.step_into() end },
                { "b", function () dap.toggle_breakpoint() end },
                { "c", function () dap.toggle_breakpoint(vim.fn.input("Enter Breakpoint Condition: ")) end },
                { "<C-j>", function () dap.down() end },
                { "<C-k>", function () dap.up() end },
                { "G", function () dap.run_to_cursor() end },
                { "K", function () require('dapui').eval() end, { mode = { 'n', 'v' } } },

                { "S", function () jump_to_element('code_win') end }, -- source code
                { "W", function () jump_to_element('dapui_watches') end }, -- watches
                { "C", function () jump_to_element('dapui_console') end }, -- console
                { "R", function () jump_to_element('dap-repl') end }, -- repl
                { "B", function () jump_to_element('dapui_breakpoints') end }, -- breakpoints
                { "T", function () jump_to_element('dapui_stacks') end }, -- traces

                { "w", function () dapui.elements.watches.add() end, { mode = { 'n', 'v' } } }, -- watch add


                { "ZZ", function ()
                    dap.terminate()
                    dapui.close()
                    vim.cmd([[:DapVirtualTextDisable]])
                end },

                { "ZR", function () dap.restart() end },
            }
        })

        hydra({
            name = "WINDOW",
            mode = "n",
            body = "<C-W>",
            heads = {
                { 'h', '<C-w>h' },
                { 'j', '<C-w>j' },
                { 'k', '<C-w>k' },
                { 'l', '<C-w>l' },
                { 's', '<C-w>s' },
                { 'v', '<C-w>v' },
                { '+', '<C-w>+' },
                { '-', '<C-w>-' },
                { '>', '<C-w>>' },
                { '<', '<C-w><' },
                { '=', '<C-w>=' },
                { 'q', '<cmd>close<CR>' },
                { 'o', '<cmd>only<CR>' },
                { '_', '<C-w>_' },
                { '|', '<C-w>|' },
                { '<Esc>', nil,  { exit = true, desc = false } },
            },
        })
    end
}
