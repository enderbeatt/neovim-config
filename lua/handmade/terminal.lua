local M = {
    term_buf = nil,
    term_win = nil,
    terminal_config = {
        split = "below",
        win = 0,
        height = 20,
    }
}

function M.force_start_terminal(cmd)
    if M.term_buf ~= nil then
        M.quit_terminal()
    end
    M.term_buf = vim.api.nvim_create_buf(false, true)
    M.term_win = vim.api.nvim_open_win(M.term_buf, true, M.terminal_config)
    vim.cmd.terminal(cmd)
end

function M.toggle_terminal(cmd)
    if M.term_buf == nil or not vim.api.nvim_buf_is_valid(M.term_buf) then
        M.term_buf = vim.api.nvim_create_buf(false, true)
    end

    if M.term_win == nil or not vim.api.nvim_win_is_valid(M.term_win) then
        M.term_win = vim.api.nvim_open_win(M.term_buf, true, M.terminal_config)
    else
        vim.api.nvim_win_hide(M.term_win)
    end

    if M.term_buf ~= nil and vim.bo[M.term_buf].buftype ~= "terminal" then
        vim.cmd.terminal(cmd)
    end
end

function M.hide_terminal()
    if M.term_win ~= nil and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_hide(M.term_win)
    end
end

function M.quit_terminal()
    if M.term_win ~= nil and vim.api.nvim_win_is_valid(M.term_win) then
        vim.api.nvim_win_hide(M.term_win)
    end
    vim.api.nvim_buf_delete(M.term_buf, {})
end

return M
