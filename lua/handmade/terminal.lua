TERM_BUF = nil
TERM_WIN = nil

local function toggle_terminal()
    if TERM_BUF == nil or not vim.api.nvim_buf_is_valid(TERM_BUF) then
        TERM_BUF = vim.api.nvim_create_buf(false, true)
    end

    if TERM_WIN == nil or not vim.api.nvim_win_is_valid(TERM_WIN) then
        TERM_WIN = vim.api.nvim_open_win(TERM_BUF, true, {
            split = "below",
            win = 0,
            height = 15,
        })
    else
        vim.api.nvim_win_hide(TERM_WIN)
    end

    if TERM_BUF ~= nil and vim.bo[TERM_BUF].buftype ~= "terminal" then
        vim.cmd.terminal()
    end
end


vim.keymap.set({"n", "t"}, "<C-t>", toggle_terminal, { noremap = true, silent = true })



















