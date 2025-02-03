vim.api.nvim_create_user_command("Test", 'echo "lol"', {
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
