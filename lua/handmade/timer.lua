local M = { set_time = nil }

function M.update_timer()
    if M.set_time == nil then
        return ""
    end
    local cur_time = os.time()
    if M.set_time > cur_time then
        local delta = M.set_time - cur_time
        local _ = vim.fn.timer_start(1000, M.update_timer)
        return os.date("!%H:%M:%S", delta)
    else
        return "TIME IS UP"
    end
end

function M.set_timer()
    local hrs = tonumber(vim.fn.input("Enter hours: ")) or 0
    local min = tonumber(vim.fn.input("Enter minutes: ")) or 0
    local sec = tonumber(vim.fn.input("Enter seconds: ")) or 0
    local delta = os.date("*t", hrs * 3600 + min * 60 + sec)

    local cur_time = os.time()
    M.set_time = os.time(delta) + cur_time

    M.update_timer()
end


vim.api.nvim_create_user_command("Timer", M.set_timer, {})
vim.api.nvim_create_user_command("TimerDismiss", function ()
    M.set_time = nil
end, {})

return M
