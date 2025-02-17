local term = require('handmade.terminal')
local unexpanded_cmd = nil

local function task_run(opts)
    unexpanded_cmd = table.concat(opts.fargs, ' ')
    local cmd = vim.fn.expandcmd(unexpanded_cmd)
    term.force_start_terminal(cmd)
end

local function task_restart()
    local cmd = vim.fn.expandcmd(unexpanded_cmd)
    term.force_start_terminal(cmd)
end

local function send_to_quickfix()
    if term.term_buf == nil or not vim.api.nvim_buf_is_valid(term.term_buf) then
        return
    end
    local bufnr = term.term_buf
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    vim.fn.setqflist({}, " ", {
        lines = lines,
    })
    term.hide_terminal()
    vim.cmd("botright copen")
end

vim.api.nvim_create_user_command("RunShell", task_run, {
    nargs = "+",
    complete = function(ArgLead, CmdLine, _)
        local args = vim.split(CmdLine, ' ', {plain=true,trimempty=true})
        if #args + (#ArgLead == 0 and 1 or 0) <= 2 then
            return vim.fn.getcompletion(ArgLead, "shellcmd")
        else
            return vim.fn.getcompletion(ArgLead, "file")
        end
    end
})

vim.api.nvim_create_user_command("SendToQuickfix", send_to_quickfix, {})
vim.api.nvim_create_user_command("RestartTask", task_restart, {})

vim.keymap.set('n', '<leader>tr', [[:RestartTask<cr>]], {desc = '[T]ask [R]estart'});
vim.keymap.set('n', '<leader>ts', [[:RunShell ]], {desc = '[T]ask [S]hell'});
vim.keymap.set('n', '<leader>tq', [[:SendToQuickfix<cr>]], {desc = '[T]ask [Q]uickfix'});
