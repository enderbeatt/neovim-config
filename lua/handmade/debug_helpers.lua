local M = {}
M.values = {}
M.prompts = {}
M.completions = {}

--- @param path string
--- @return string
function M.get_executable_path(path)
    if vim.fn.has("win32") ~= 0 then
        return vim.fn.expand("~") .. "/AppData/Local/nvim-data/" .. path .. ".exe"
    else
        return vim.fn.expand("~") .. "/.local/share/nvim/" .. path
    end
end

--- @param type_str string
--- @param prompt? string
--- @param default? string
--- @param completion? string
--- @return string
function M.get_or_input(type_str, prompt, default, completion)
    prompt = prompt or ""
    local val = M.values[type_str]
    vim.print(val)
    if val == nil then
        val = vim.fn.input{prompt = prompt, default = default, completion = completion}
        M.values[type_str] = val
        M.prompts[type_str] = prompt
        M.completions[type_str] = completion
    end
    return val
end


--- @param type_str string
--- @param prompt? string
--- @param default? string
--- @param completion? string
--- @return string?
function M.get_or_input_nil(type_str, prompt, default, completion)
    local val = M.get_or_input(type_str, prompt, default, completion)
    if val == "" then
        M.values[type_str] = nil
        return nil
    end
    return val
end

--- @param type_str string
function M.update_str(type_str)
    M.values[type_str] = vim.fn.input(M.prompts[type_str], M.values[type_str], M.completions[type_str])
end

return M
