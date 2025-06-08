local M = {
    term_bufs = {},
    term_win = nil,
    terminal_config = {
        split = "below",
        win = 0,
        height = 20,
    }
}

function M.prepare_terminal(idx)
    local new_buf = vim.api.nvim_create_buf(false, true)
    M.term_bufs[idx] = new_buf
end

function M.append_terminal(cmd)
    M.hide_terminal()
    M.toggle_terminal(#M.term_bufs + 1, cmd)
end

function M.toggle_terminal(idx, cmd, restart)
    if idx == nil then
        idx = #M.term_bufs
        if idx == 0 then
            idx = 1
        end
    end

    if restart then
        M.quit_terminal(idx)
    end

    local new_terminal = M.term_bufs[idx] == nil


    if new_terminal then
        M.prepare_terminal(idx)
    end

    local term_buf = M.term_bufs[idx]

    if M.term_win == nil or not vim.api.nvim_win_is_valid(M.term_win) then
        M.term_win = vim.api.nvim_open_win(term_buf, true, M.terminal_config)
    else
        vim.api.nvim_win_hide(M.term_win)
    end

    if new_terminal then
        vim.cmd.terminal(cmd)
    end
end

function M.go_to_terminal(idx)
    M.hide_terminal()
    M.toggle_terminal(idx)
end

function M.quit_terminal(idx)
    if M.term_win ~= nil and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_hide(M.term_win)
    end
    if M.term_bufs[idx] ~= nil and vim.api.nvim_buf_is_valid(M.term_bufs[idx]) then
        vim.api.nvim_buf_delete(M.term_bufs[idx], {})
    end
    M.term_bufs[idx] = nil
end

function M.hide_terminal()
    if M.term_win ~= nil and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_hide(M.term_win)
    end
end

return M
