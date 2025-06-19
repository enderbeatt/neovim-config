local M = {
    term_bufs = {},
    term_win = nil,
    last_term_idx = nil,
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

function M.insert_terminal(cmd)
    M.hide_terminal()
    M.toggle_terminal(M.find_vacant_place(), cmd)
    return M.last_term_idx
end

function M.find_vacant_place()
    local idx = 1
    while M.term_bufs[idx] do
        idx = idx + 1
    end
end

function M.toggle_terminal(idx, cmd, restart)
    if idx == nil then
        idx = M.last_term_idx
    end

    if idx == nil then
        idx = M.find_vacant_place()
    end

    if restart then
        M.quit_terminal(idx)
    end

    local new_terminal = not M.is_valid_terminal(idx)

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

    M.last_term_idx = idx
end

function M.go_to_terminal(idx)
    M.hide_terminal()
    M.toggle_terminal(idx)
end

function M.is_valid_terminal(idx)
    return M.term_bufs[idx] ~= nil and vim.api.nvim_buf_is_valid(M.term_bufs[idx])
end

function M.quit_terminal(idx)
    if M.term_win ~= nil and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_hide(M.term_win)
    end
    if M.is_valid_terminal(idx) then
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
