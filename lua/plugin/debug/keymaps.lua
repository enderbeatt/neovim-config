---jump to the window of specified dapui element
---@param element string filetype of the element or 'code_win' for the code window
local function jump_to_element(element)
    local visible_wins = vim.api.nvim_tabpage_list_wins(0)
    local dap_configurations = require('dap').configurations
    for _, win in ipairs(visible_wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        print(vim.bo[buf].filetype)
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

---@param start integer[]
---@param finish integer[]
local function get_selection(start, finish)
    local start_line, start_col = start[2], start[3]
    local finish_line, finish_col = finish[2], finish[3]

    if start_line > finish_line or (start_line == finish_line and start_col > finish_col) then
        start_line, start_col, finish_line, finish_col = finish_line, finish_col, start_line, start_col
    end

    local lines = vim.fn.getline(start_line, finish_line)
    if #lines == 0 then
        return
    end
    lines[#lines] = string.sub(lines[#lines], 1, finish_col)
    lines[1] = string.sub(lines[1], start_col)
    return lines
end

local function get_current_expr()
    if vim.fn.mode() == "v" then
        local start = vim.fn.getpos("v")
        local finish = vim.fn.getpos(".")
        local lines = get_selection(start, finish)
        return table.concat(lines, "\n")
    end
    return vim.fn.expand("<cexpr>")
end

return {
    "nvimtools/hydra.nvim",
    config = function()
        local hydra = require('hydra')
        local dap = require('dap')
        local dv = require("dap-view")
        local native_mode = ""

        hydra({
            name = "DEBUG",
            mode = "n",
            body = "<leader>d",
            config = {
                color = 'pink',
            },
            heads = {
                { "f",     nil }, -- just to easily return in debug mode if i fell out of it
                { "I", function()
                    dap.continue()
                    vim.cmd([[:DapVirtualTextEnable]])
                end },
                { "J",     function() dap.step_over() end },
                { "H",     function() dap.step_out() end },
                { "L",     function() dap.step_into() end },
                { "b",     function() dap.toggle_breakpoint() end },
                { "c",     function() dap.toggle_breakpoint(vim.fn.input("Enter Breakpoint Condition: ")) end },
                { "<C-j>", function() dap.down() end },
                { "<C-k>", function() dap.up() end },
                { "G",     function() dap.run_to_cursor() end },
                { "K", function()
                    -- require('dapui').eval(native_mode .. util.get_current_expr())
                    require('dap.ui.widgets').hover(native_mode .. get_current_expr())
                    if vim.fn.mode() == 'v' then
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
                    end
                end, { mode = { 'n', 'v' } } },

                { "S", function() jump_to_element('code_win') end },           -- source code
                { "C", function() jump_to_element('dap-view-term') end },      -- console
                { "W", function() dv.show_view('watches') end },               -- watches
                { "R", function() dv.show_view('repl') end },                  -- repl
                { "B", function() dv.show_view('breakpoints') end },           -- breakpoints
                { "T", function() dv.show_view('threads') end },               -- traces

                { "w", function()
                    dv.add_expr(native_mode .. get_current_expr())
                    if vim.fn.mode() == 'v' then
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', false, true, true), 'nx', false)
                    end
                end, { mode = { 'n', 'v' } } }, -- watch add
                { "n", function()
                    if native_mode == "" then
                        native_mode = "/nat "
                    else
                        native_mode = ""
                    end
                end, { mode = { 'n', 'v' } } }, -- toggle native mod

                { "ZZ", function()
                    dap.terminate()
                    dv.close(true)
                    vim.cmd([[:DapVirtualTextDisable]])
                end, { exit = true } },
            }
        })
    end
}
