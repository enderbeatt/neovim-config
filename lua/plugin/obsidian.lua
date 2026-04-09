local function get_vault_dir()
    if vim.uv.os_uname().sysname == "Linux" then
        return "~/obsidian-vault"
    else
        return "E:\\obsidian-vault"
    end
end

return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    config = function ()
        require('obsidian').setup({
            legacy_commands = false,
            workspaces = {
                {
                    name = "vault",
                    path = get_vault_dir(),
                },
            },
            picker = {
                name = "snacks.pick",
            },
            completion = {
                blink = true,
            },
            templates = {
                folder = "templates",
                date_format = "%Y-%m-%d",
                time_format = "%H:%M",
            },
            note_id_func = function(title)
                local date = os.date("%Y-%m-%d %H:%M")
                local filename = vim.trim(date .. " " .. (title or "")) .. ".md"
                return filename
            end
        })
        vim.keymap.set("n", "<leader>oo", [[:Obsidian open<cr>]],              { desc = "Open Obsidian" })
        vim.keymap.set("n", "<leader>on", [[:Obsidian new_from_template<cr>]], { desc = "Create a note from template" })
        vim.keymap.set("n", "<leader>os", [[:Obsidian search<cr>]],            { desc = "Search In Obsidian Vault" })
        vim.keymap.set("n", "<leader>ob", [[:Obsidian backlinks<cr>]],         { desc = "Look at backlinks" })
        vim.keymap.set("n", "<leader>ot", [[:Obsidian tags<cr>]],              { desc = "Search through tags" })
    end
}
