local M = {}
M.values = {}
M.factories = {}

--- @return boolean
function M.is_dap_window(ft)
    local dap_windows = {
        ["dapui_watches"] = 1,
        ["dapui_scopes"] = 1,
        ["dapui_breakpoints"] = 1,
        ["dapui_stacks"] = 1,
        ["dap-terminal"] = 1,
        ["dap-repl"] = 1,
    }
    return dap_windows[ft] ~= nil
end


--- @param path string
--- @return string
function M.get_executable_path(path)
    if vim.fn.has("win32") ~= 0 then
        return vim.fn.expand("~") .. "/AppData/Local/nvim-data/" .. path .. ".exe"
    else
        return vim.fn.expand("~") .. "/.local/share/nvim/" .. path
    end
end

--- @param prompt? string
--- @param default? string
--- @param completion? string
--- @return function
function M.input(prompt, default, completion)
    prompt = prompt or ""
    return function ()
        vim.fn.input{prompt = prompt, default = default, completion = completion}
    end
end

--- @return function
function M.pick_executable()
    return function()
        local co = coroutine.running()
        require("snacks").picker.pick({
            source = "executables",
            layout = "select",
            format = "text",
            finder = function(config, ctx)
                return require("snacks.picker.source.proc").proc({
                    config,
                    {
                        cmd = "fdfind",
                        args = { "-tx", "-I", "--color", "never" },
                    }
                }, ctx)
            end,
            confirm = function(picker, item)
                picker:close()
                coroutine.resume(co, item.text)
            end
        })
        return coroutine.yield()
    end
end

--- @param type_str string
--- @param factory function
--- @return string
function M.get_or(type_str, factory)
    local val = M.values[type_str]
    if val == nil then
        val = factory()
        M.values[type_str] = val
        M.factories[type_str] = factory
    end
    return val
end


--- @param type_str string
--- @param factory function
--- @return string?
function M.get_or_nil(type_str, factory)
    local val = M.get_or(type_str, factory)
    if val == "" then
        return nil
    end
    return val
end

--- @param type_str string
function M.update_str(type_str)
    M.values[type_str] = M.factories[type_str]()
end

return M
