local function task_run (opts)
    local cmd = vim.fn.expandcmd(table.concat(opts.fargs, ' '))
    local term = require('handmade.terminal')
    term.toggle_terminal(cmd)
end

vim.api.nvim_create_user_command("Test", task_run, {
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
