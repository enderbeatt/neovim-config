local term = require('handmade.terminal')
local unexpanded_cmd = nil

local function task_run(opts)
    unexpanded_cmd = table.concat(opts.fargs, ' ')
    local cmd = vim.fn.expandcmd(unexpanded_cmd)
    term.append_terminal(cmd)
end

local function task_restart()
    local cmd = vim.fn.expandcmd(unexpanded_cmd)
    term.toggle_terminal(nil, cmd, true)
end

local function send_to_quickfix()
    vim.print("not implemented")
    -- if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
    --     return
    -- end
    -- local bufnr = term_buf
    -- local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    -- vim.fn.setqflist({}, " ", {
    --     lines = lines,
    -- })
    -- term.hide_terminal()
    -- vim.cmd("botright copen")
end

local function go_to_term(opts)
    if opts.fargs[1] == nil then
        term.toggle_terminal()
    else
        term.go_to_terminal(tonumber(opts.fargs[1]))
    end
end

vim.api.nvim_create_user_command("RunShell", task_run, {
    nargs = "+",
    complete = function(ArgLead, CmdLine, _)
        local args = vim.split(CmdLine, ' ', { plain = true, trimempty = true })
        if #args + (#ArgLead == 0 and 1 or 0) <= 2 then
            return vim.fn.getcompletion(ArgLead, "shellcmd")
        else
            return vim.fn.getcompletion(ArgLead, "file")
        end
    end
})


vim.api.nvim_create_user_command("SendToQuickfix", send_to_quickfix, {})
vim.api.nvim_create_user_command("RestartTask", task_restart, {})
vim.api.nvim_create_user_command("GoToTerm", go_to_term, {
    nargs = "?",
})

vim.keymap.set('n', '<leader>tr', [[:RestartTask<cr>]], { desc = '[T]ask [R]estart' });
vim.keymap.set('n', '<leader>ts', [[:RunShell ]], { desc = '[T]ask [S]hell' });
vim.keymap.set('n', '<leader>tq', [[:SendToQuickfix<cr>]], { desc = '[T]ask [Q]uickfix' });

vim.keymap.set({ 'n', 't' }, '<C-t>', function()
    term.toggle_terminal()
end, { desc = 'Go to recent terminal' });
vim.keymap.set({ 'n', 't' }, '<M-1>', function()
    term.go_to_terminal(1)
end, { desc = 'Go to terminal #1' });
vim.keymap.set({ 'n', 't' }, '<M-2>', function()
    term.go_to_terminal(2)
end, { desc = 'Go to terminal #2' });
vim.keymap.set({ 'n', 't' }, '<M-3>', function()
    term.go_to_terminal(3)
end, { desc = 'Go to terminal #3' });
vim.keymap.set({ 'n', 't' }, '<M-4>', function()
    term.go_to_terminal(4)
end, { desc = 'Go to terminal #4' });
