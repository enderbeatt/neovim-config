local M = {}

local function quickfix_window()
    return vim.fn.getqflist({ winid = 0 }).winid
end

function M.place_below(target_win)
    local qf_win = quickfix_window()
    if qf_win == 0 or qf_win == target_win then
        return false
    end

    local moved = vim.fn.win_splitmove(qf_win, target_win, { rightbelow = true })
    if moved ~= 0 then
        return false
    end

    vim.api.nvim_set_current_win(target_win)
    return true
end

function M.open(opts)
    local target_win = vim.api.nvim_get_current_win()
    require("quicker").open(opts)
    M.place_below(target_win)
end

function M.toggle(opts)
    local quicker = require("quicker")
    if quicker.is_open() then
        quicker.close()
    else
        M.open(opts)
    end
end

return M
