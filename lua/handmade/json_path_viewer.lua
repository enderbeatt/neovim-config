local function get_json_path(bufnr)
    local node = vim.treesitter.get_node({ bufnr = bufnr })
    if not node then
        return "No Treesitter node found"
    end

    local path = {}
    while node do
        if node:type() == "pair" then
            local key = node:field("key")[1]
            table.insert(path, 1, (vim.treesitter.get_node_text(key, bufnr):gsub('"', "")))
        else
            local parent = node:parent()
            if parent and parent:type() == "array" and node:named() then
                local index = 0
                for child in parent:iter_children() do
                    if child == node then
                        table.insert(path, 1, ("[%d]"):format(index))
                        break
                    end
                    if child:named() then
                        index = index + 1
                    end
                end
            end
        end
        node = node:parent()
    end

    return #path == 0 and "Cursor is not inside a JSON object" or table.concat(path, ".")
end

vim.keymap.set("n", "<leader>jp", function()
    local path = get_json_path(vim.api.nvim_get_current_buf())
    vim.fn.setreg('"', path)
    vim.api.nvim_echo({ { "Yanked JSON Path: " .. path, "Normal" } }, false, {})
end, { desc = "Yank JSON path" })

return { get_json_path = get_json_path }
