local M = {}

---@class handmade.vcs.Provider
---@field kind string
---@field root fun(cwd: string): string?
---@field open fun(cwd: string)

---@alias handmade.vcs.Selection {kind: 'none', cwd: string}|{kind: string, root: string, cwd: string}

---External commands are the boundary between an optional tool and a repository.
---@param command string[]
---@param cwd string
---@return string?
function M.probe(command, cwd)
    if vim.fn.executable(command[1]) == 0 then
        return nil
    end
    local result = vim.system(command, { cwd = cwd, text = true }):wait()
    if result.code == 0 then
        return vim.uv.fs_realpath(vim.trim(result.stdout))
    end
end

local providers = {
    git = {
        kind = "git",
        root = function(cwd)
            return M.probe({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, cwd)
        end,
        open = function(cwd)
            require("neogit").open({ cwd = cwd })
        end,
    },
}

---@param provider handmade.vcs.Provider
function M.register(provider)
    providers[provider.kind] = provider
end

---@param cwd? string
---@return handmade.vcs.Selection
function M.select(cwd)
    cwd = assert(vim.uv.fs_realpath(cwd or vim.fn.getcwd()))
    local selected = { kind = "none", cwd = cwd }
    for _, provider in pairs(providers) do
        local root = provider.root(cwd)
        if root then
            root = assert(vim.uv.fs_realpath(root))
            local prefix = root == "/" and root or root .. "/"
            local contains = cwd == root or cwd:sub(1, #prefix) == prefix
            if contains and (not selected.root or #root > #selected.root
                or (#root == #selected.root and provider.kind == "git")) then
                selected = { kind = provider.kind, root = root, cwd = cwd }
            end
        end
    end
    return selected
end

function M.open()
    local selected = M.select()
    local provider = providers[selected.kind == "none" and "git" or selected.kind]
    return provider.open(selected.cwd)
end

return M
