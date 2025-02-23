local M = { set_time = nil }

function M.update_timer()
    if M.set_time == nil then
        return ""
    end
    local cur_time = os.time()
    vim.print(M.set_time - cur_time)
    if M.set_time > cur_time then
        local delta = M.set_time - cur_time
        local timer = vim.fn.timer_start(1000, M.update_timer)
        return os.date("!%H:%M:%S", delta)
    else
        return "TIME IS UP"
    end
end

function M.set_timer(str)
    local cur_time = os.time()

    local sec = tonumber(str.fargs[1])
    local delta = os.date("*t", 0)
    delta.sec = sec

    M.set_time = os.time(delta) + cur_time

    M.update_timer()
end


vim.api.nvim_create_user_command("Timer", M.set_timer, { nargs = "+" })
vim.api.nvim_create_user_command("TimerDismiss", function ()
    M.set_time = nil
end, {})

return M
