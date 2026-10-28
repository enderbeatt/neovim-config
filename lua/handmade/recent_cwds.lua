local M = {}
local history_path = vim.fn.stdpath("state") .. "/recent_cwds.json"

local function read_history()
    if vim.fn.filereadable(history_path) == 0 then
        return {}
    end
    return vim.json.decode(table.concat(vim.fn.readfile(history_path), "\n"))
end

local function record(cwd)
    cwd = vim.fs.normalize(cwd)
    -- Read on each change to retain visits recorded by other Neovim sessions.
    local history = read_history()
    if history[1] == cwd then
        return
    end
    for i, path in ipairs(history) do
        if path == cwd then
            table.remove(history, i)
            break
        end
    end
    table.insert(history, 1, cwd)

    vim.fn.mkdir(vim.fn.stdpath("state"), "p")
    -- Replace atomically so other sessions never read a partially written file.
    local temporary = history_path .. "." .. vim.fn.getpid() .. ".tmp"
    vim.fn.writefile({ vim.json.encode(history) }, temporary)
    assert(vim.uv.fs_rename(temporary, history_path))
end

function M.setup()
    vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("RecentCwds", { clear = true }),
        callback = function()
            record(vim.v.event.cwd)
        end,
    })
    record(vim.fn.getcwd())
end

function M.pick()
    return require("snacks").picker.pick({
        source = "recent_cwds",
        title = "Recent Working Directories",
        layout = "select",
        format = "file",
        sort = { fields = { "score:desc", "idx" } },
        finder = function()
            local items = {}
            for _, cwd in ipairs(read_history()) do
                if vim.fn.isdirectory(cwd) == 1 then
                    items[#items + 1] = { text = cwd, file = cwd, dir = true }
                end
            end
            return items
        end,
        confirm = function(picker, item)
            if not item then
                return
            end
            picker:close()
            vim.api.nvim_win_call(picker.main, function()
                vim.cmd.cd({ args = { item.file } })
                vim.cmd.edit({ args = { item.file } })
            end)
        end,
    })
end

return M
